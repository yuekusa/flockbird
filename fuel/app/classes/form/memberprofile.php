<?php

class Form_MemberProfile
{
	private $page_type = null;
	private $profiles = null;
	private $member_obj = null;
	private $member_profiles_profile_id_indexed = array();
	private $member_public_flags = array();
	private $member_profile_public_flags = array();
	private $validation = null;
	private $validated_values = array();

	public function __construct($page_type, Model_Member $member_obj = null)
	{
		if (!in_array($page_type, array('regist', 'config'))) throw new InvalidArgumentException('First parameter is invalid.');
		$this->page_type = $page_type;
		$this->member_obj = $member_obj;
		$this->profiles = Model_Profile::get4page_type($page_type);
		$this->set_member_profiles_profile_id_indexed();
		$this->set_public_flags();
	}

	private static function conf($item, $optional_item = null, $default = null)
	{
		if ($optional_item) $item .= '.'.$optional_item;

		return conf('profile.'.$item, null, $default);
	}

	public function set_member_obj(Model_Member $member_obj)
	{
		$this->member_obj = $member_obj;
	}

	public function set_member_profiles_profile_id_indexed()
	{
		$member_profiles = $this->member_obj ? Model_MemberProfile::get4member_id($this->member_obj->id) : array();
		$this->member_profiles_profile_id_indexed = self::convert2member_profiles_profile_id_indexed($this->profiles, $member_profiles);
	}

	public function get_profiles()
	{
		return $this->profiles;
	}

	public function get_validation()
	{
		return $this->validation;
	}

	public function get_member_public_flags()
	{
		return $this->member_public_flags;
	}

	public function get_member_profile_public_flags()
	{
		return $this->member_profile_public_flags;
	}

	public function validate_public_flag()
	{
		$this->validate_public_flag_member('sex');
		$this->validate_public_flag_member('birthday');
		$this->validate_public_flag_member_profile();
	}

	private function validate_public_flag_member($name)
	{
		if (!$this->check_is_enabled_member_field($name)) return;
		$this->validate_public_flag_each('member_public_flag', $name);
	}

	private function validate_public_flag_member_profile()
	{
		foreach ($this->profiles as $profile)
		{
			if (!$profile->is_edit_public_flag) continue;
			$this->validate_public_flag_each('member_profile_public_flag', $profile->id);
		}
	}

	private function validate_public_flag_each($post_param, $key)
	{
		$values = Input::post($post_param);
		if (!isset($values[$key])) return;
		if (in_array($values[$key], Site_Util::get_public_flags())) return;

		throw new HttpInvalidInputException('公開範囲の値が不正です。');
	}

	public function seve()
	{
		if (!$this->member_obj) throw new FuelException('Member Object is not set.');;
		$this->save_member();
		$this->save_member_profile();
	}

	private function check_is_set_field($field)
	{
		return $this->validation->fieldset()->field($field);
	}

	private function set_member_obj_value($prop)
	{
		$field = 'member_'.$prop;
		if (!$this->check_is_set_field($field)) return false;

		$this->member_obj->$prop = $this->validated_values[$field];

		return $this->member_obj->is_changed($prop);
	}

	private function set_member_obj_public_flag($prop, $is_check_set_field = true, $public_flag_prop = null)
	{
		$field = 'member_'.$prop;
		if ($is_check_set_field && !$this->check_is_set_field($field)) return false;

		if (!$public_flag_prop) $public_flag_prop = $prop.'_public_flag';
		$this->member_obj->$public_flag_prop = $this->member_public_flags[$prop];

		return $this->member_obj->is_changed($public_flag_prop);
	}

	private function save_member()
	{
		$is_changeed = array();
		if ($this->set_member_obj_value('name')) $is_changeed[] = 'name';
		if ($this->set_member_obj_value('sex'))  $is_changeed[] = 'sex';
		if ($this->set_member_obj_public_flag('sex')) $is_changeed[] = 'sex_public_flag';
		if ($this->set_member_obj_value('birthyear'))  $is_changeed[] = 'birthyear';
		if ($this->set_member_obj_public_flag('birthyear')) $is_changeed[] = 'birthyear_public_flag';

		if ($this->check_is_set_field('member_birthday_month') && $this->check_is_set_field('member_birthday_day'))
		{
			$this->member_obj->birthday = Util_Date::combine_date_str($this->validated_values['member_birthday_month'], $this->validated_values['member_birthday_day']);
			if ($this->member_obj->is_changed('birthday')) $is_changeed[] = 'birthday';
		}
		if ($this->set_member_obj_public_flag('birthday', false)) $is_changeed[] = 'birthday_public_flag';

		if (!$is_changeed) return;
		$this->member_obj->save();

		// timeline 投稿
		if (!is_enabled('timeline')) return;
		if (!in_array('name', $is_changeed)) return;
		$body = sprintf('%sを %s に変更しました。', term('member.name'), $this->member_obj->name);
		\Timeline\Site_Model::save_timeline($this->member_obj->id, PRJ_PUBLIC_FLAG_ALL, 'member_name', $this->member_obj->id, $body);
	}

	private function save_member_profile()
	{
		foreach ($this->profiles as $profile)
		{
			$profile_options = $profile->profile_option;
			if ($profile->form_type == 'checkbox')
			{
				$member_profiles = (array)$this->member_profiles_profile_id_indexed[$profile->id];
				foreach ($profile_options as $profile_option)
				{
					if (isset($this->validated_values[$profile->name]) && in_array($profile_option->id, $this->validated_values[$profile->name]))
					{
						$member_profile = isset($member_profiles[$profile_option->id]) ? $member_profiles[$profile_option->id] : Model_MemberProfile::forge();
						$member_profile->member_id = $this->member_obj->id;
						$member_profile->profile_id = $profile->id;
						$member_profile->profile_option_id = $profile_option->id;
						if ($profile->is_edit_public_flag)
						{
							$member_profile->public_flag = $this->member_profile_public_flags[$profile->id];
						}
						else
						{
							$member_profile->public_flag = $profile->default_public_flag;
						}
						$member_profile->value = $profile_option->label;
						$member_profile->save();
					}
					else
					{
						if (!isset($member_profiles[$profile_option->id])) continue;
						$member_profiles[$profile_option->id]->delete();
					}
				}
			}
			else
			{
				$member_profile = $this->member_profiles_profile_id_indexed[$profile->id];
				if (is_null($member_profile)) $member_profile = Model_MemberProfile::forge();
				$member_profile->member_id = $this->member_obj->id;
				$member_profile->profile_id = $profile->id;
				if ($profile->is_edit_public_flag)
				{
					$member_profile->public_flag = $this->member_profile_public_flags[$profile->id];
				}
				else
				{
					$member_profile->public_flag = $profile->default_public_flag;
				}

				if (in_array($profile->form_type, array('radio', 'select')))
				{
					$profile_option_id = $this->validated_values[$profile->name];
					$member_profile->profile_option_id = $profile_option_id;
					$member_profile->value = $profile_options[$profile_option_id]->label;
				}
				else
				{
					$member_profile->value = $this->validated_values[$profile->name];
				}

				$member_profile->save();
			}
		}
	}

	public function set_validation_message($rule, $message)
	{
		$this->validation->set_message($rule, $message);
	}

	private function check_is_enabled_member_field($name)
	{
		if (self::check_is_birthday_item($name)) $name = 'birthday';

		if ($name == 'name' && $this->page_type == 'regist') return true;
		if ($name != 'name' && !self::conf($name, 'isEnable')) return false;

		return (bool)self::conf($name, 'isDisp'.ucfirst($this->page_type));
	}

	private function set_validation_member_field($name)
	{
		if (!$this->check_is_enabled_member_field($name)) return false;

		$properties = Form_Util::get_model_field('member', $name);
		$attrs = $properties['attributes'];
		$attrs['value'] = $this->member_obj ? $this->member_obj->$name : '';

		if (self::conf($name, 'isRequired'))
		{
			$properties['rules'][] = 'required';
		}

		$this->validation->add(
			'member_'.$name,
			$properties['label'],
			$attrs,
			$properties['rules']
		);
	}

	private function set_validation_member_field_birthday()
	{
		if (!$this->check_is_enabled_member_field('birthday')) return false;

		$properties = Form_Util::get_model_field('member', 'birthyear');
		$attrs = $properties['attributes'];
		$attrs['value'] = isset($this->member_obj->birthyear) ? $this->member_obj->birthyear : date('Y');
		if (self::conf('birthday', 'birthyear.isRequired')) $properties['rules'][] = 'required';
		$this->validation->add(
			'member_birthyear',
			$properties['label'],
			$attrs,
			$properties['rules']
		);

		list($month, $day) = isset($this->member_obj->birthday) ? Util_Date::sprit_date_str($this->member_obj->birthday) : array(1, 1);
		if (self::conf('birthday', 'birthday.isRequired')) $rules[] = 'required';

		$options = Form_Util::get_int_options(1, 12);
		$rules = array(
			array('valid_string', 'numeric'),
			array('in_array', array_keys($options)),
		);
		$this->validation->add(
			'member_birthday_month',
			'誕生日(月)',
			array('type' => 'select', 'options' => $options, 'value' => $month),
			$rules
		);

		$options = Form_Util::get_int_options(1, 31);
		$rules = array(
			array('valid_string', 'numeric'),
			array('in_array', array_keys($options)),
		);
		$this->validation->add(
			'member_birthday_day',
			'誕生日(日)',
			array('type' => 'select', 'options' => $options, 'value' => $month),
			$rules
		);
	}

	public function set_validation($add_fields = array())
	{
		$this->validation = \Validation::forge();

		// member
		$this->set_validation_member_field('name');
		$this->set_validation_member_field('sex');
		$this->set_validation_member_field_birthday();

		// member_profile
		foreach ($this->profiles as $profile)
		{
			$member_profile = $this->member_profiles_profile_id_indexed[$profile->id];
			$rules = array();
			if ($profile->is_required) $rules[] = 'required';
			switch ($profile->form_type)
			{
				case 'input':
				case 'textarea':
					$type = 'text';
					if ($profile->value_type == 'email')
					{
						$type = 'email';
						$rules[] = 'valid_email';
					}
					elseif ($profile->value_type == 'integer')
					{
						$type = 'number';
						$rules[] = array('valid_string', 'numeric');
					}
					elseif ($profile->value_type == 'url')
					{
						$type = 'url';
						$rules[] = 'valid_url';
					}
					elseif ($profile->value_type == 'regexp')
					{
						$rules[] = array('match_pattern', $profile->value_regexp);
					}
					if ($profile->form_type == 'textarea') $type = 'textarea';

					if ($profile->value_min)
					{
						$rule_name = ($profile->value_type == 'integer') ? 'numeric_min' : 'min_length';
						$rules[] = array($rule_name, $profile->value_min);
					}
					if ($profile->value_max)
					{
						$rule_name = ($profile->value_type == 'integer') ? 'numeric_max' : 'max_length';
						$rules[] = array($rule_name, $profile->value_max);
					}

					if ($profile->is_unique)
					{
						$rules[] = array('unique', 'member_profile.value', array(array('profile_id', $profile->id)));
					}

					$value = !is_null($member_profile) ? $member_profile->value : '';

					$this->validation->add(
						$profile->name,
						$profile->caption,
						array('type' => $type, 'value' => $value, 'placeholder' => $profile->placeholder),
						$rules
					);
					break;

				case 'select':
				case 'radio':
					$type = $profile->form_type;
					$options = Util_Orm::conv_cols2assoc($profile->profile_option, 'id', 'label');
					if (is_null($member_profile))
					{
						$options_keys = array_keys($options);
						$value = array_shift($options_keys);
					}
					else
					{
						$value = $member_profile->profile_option_id;
					}
					$rules[] = array('valid_string', 'numeric');
					$rules[] = array('in_array', array_keys($options));

					$this->validation->add(
						$profile->name,
						$profile->caption,
						array('type' => $type, 'value' => $value, 'options' => $options),
						$rules
					);
					break;
				case 'checkbox':
					$type = $profile->form_type;
					$options = Util_Orm::conv_cols2assoc($profile->profile_option, 'id', 'label');
					$value = !is_null($member_profile) ? Util_Orm::conv_col2array($member_profile, 'profile_option_id') : array();
					$rules[] = array('checkbox_val', $options);
					if ($profile->is_required) $rules[] = array('checkbox_require', 1);

					$this->validation->add(
						$profile->name,
						$profile->caption,
						array('type' => $type, 'value' => $value, 'options' => $options),
						$rules
					);
					break;
			}
		}
		foreach ($add_fields as $name => $params)
		{
			$this->add_field($name, $params);
		}
	}

	public function add_field($name, $params = array())
	{
		$this->validation->add(
			$name,
			isset($params['label']) ? $params['label'] : '',
			isset($params['attributes']) ? $params['attributes'] : array(),
			isset($params['rules']) ? $params['rules'] : array()
		);
	}

	// 識別名の変更がない場合は unique を確認しない
	public function remove_unique_restraint_for_updated_value()
	{
		foreach ($this->profiles as $profile)
		{
			if (!$profile->is_unique) continue;
			if (!in_array($profile->form_type, array('input', 'textarea'))) continue;
			if (!$member_profile = $this->member_profiles_profile_id_indexed[$profile->id]) continue;
			if (trim(\Input::post($profile->name)) != $member_profile->value) continue;

			$this->validation->fieldset()->field($profile->name)->delete_rule('unique');
		}
	}

	public function validate_birthday()
	{
		if (!$this->check_is_enabled_member_field('birthyear')) return;
		if (!$this->check_is_enabled_member_field('birthday')) return;
		if (!$this->validated_values['member_birthyear']) return;
		if (!$this->validated_values['member_birthday_month']) return;
		if (!$this->validated_values['member_birthday_day']) return;

		if (!checkdate($this->validated_values['member_birthday_month'], $this->validated_values['member_birthday_day'], $this->validated_values['member_birthyear']))
		{
			throw new \FuelException(term('member.birthyear_birthday').'の日付が正しくありません。');
		}

		$birthday_datatime = sprintf(
			'%04d-%02d-%02d 00:00:00',
			$this->validated_values['member_birthyear'],
			$this->validated_values['member_birthday_month'],
			$this->validated_values['member_birthday_day']
		);
		if (!Validation::_validation_datetime_is_past($birthday_datatime))
		{
			throw new \FuelException(term('member.birthyear_birthday').'に未来の日付は登録できません。');
		}
	}

	public function validate()
	{
		if ($this->page_type == 'config') $this->remove_unique_restraint_for_updated_value();

		if (!$this->validation->run()) throw new \FuelException($this->get_validation_errors());
		$this->validated_values = $this->validation->validated();

		$this->validate_birthday();
		$this->validate_public_flag();
	}

	public function get_validation_errors()
	{
		return $this->validation->show_errors();
	}

	public function get_validated_values()
	{
		return $this->validated_values;
	}

	private static function convert2member_profiles_profile_id_indexed($profiles, $member_profiles)
	{
		$member_profiles_profile_id_indexed = array();
		foreach ($profiles as $profile)
		{
			$member_profile = self::get_member_profile($member_profiles, $profile->id, $profile->form_type == 'checkbox') ?: null;
			$member_profiles_profile_id_indexed[$profile->id] = $member_profile;
		}

		return $member_profiles_profile_id_indexed;
	}

	private function set_public_flags()
	{
		$this->set_member_public_flag('sex');
		$this->set_member_public_flag('birthyear');
		$this->set_member_public_flag('birthday');
		$this->set_member_profile_public_flag();
	}

	private function set_member_public_flag($name)
	{
		$this->member_public_flags[$name] = $this->get_member_field_default_public_flag($name);

		$prop = $name.'_public_flag';
		if ($this->member_obj && !is_null($this->member_obj->$prop))
		{
			$this->member_public_flags[$name] = $this->member_obj->$prop;
		}

		if (!$this->check_is_editable_member_field_public_flag($name)) return;

		$posted_public_flags = Input::post('member_public_flag');
		if (!isset($posted_public_flags[$name])) return;
		if (!in_array($posted_public_flags[$name], Site_Util::get_public_flags())) return;
		$this->member_public_flags[$name] = $posted_public_flags[$name];
	}

	private function check_is_editable_member_field_public_flag($name)
	{
		if (!$this->check_is_enabled_member_field($name)) return false;

		if (self::check_is_birthday_item($name))
		{
			$name = 'birthday.'.$name;
		}

		return (bool)self::conf($name, 'publicFlag.isEdit');
	}

	private function get_member_field_default_public_flag($name)
	{
		if (self::check_is_birthday_item($name))
		{
			$name = 'birthday.'.$name;
		}

		return self::conf($name, 'publicFlag.default', conf('public_flag.default'));
	}

	private static function check_is_birthday_item($name)
	{
		if ($name == 'birthyear') return true;
		if ($name == 'birthday')  return true;

		return false;
	}

	private function set_member_profile_public_flag()
	{
		$posted_public_flags = Input::post('member_profile_public_flag');
		foreach ($this->profiles as $profile)
		{
			if (!$profile->is_edit_public_flag) continue;

			$member_profile = $this->member_profiles_profile_id_indexed[$profile->id];
			if (is_array($member_profile))
			{
				$member_profile = array_shift($member_profile);
			}
			$public_flag = isset($member_profile->public_flag) ? $member_profile->public_flag : $profile->default_public_flag;
			if (isset($posted_public_flags[$profile->id])) $public_flag = $posted_public_flags[$profile->id];

			$this->member_profile_public_flags[$profile->id] = $public_flag;
		}
	}

	private static function get_member_profile($member_profiles, $profile_id, $is_array = false)
	{
		foreach ($member_profiles as $member_profile)
		{
			if ($member_profile->profile_id == $profile_id)
			{
				if (!$is_array) return $member_profile;

				if (!isset($member_profile_list)) $member_profile_list = array();
				$member_profile_list[$member_profile->profile_option_id] = $member_profile;
			}
		}
		if (isset($member_profile_list)) return $member_profile_list;

		return false;
	}
}