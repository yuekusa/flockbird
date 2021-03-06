<?php
namespace Message;

class Site_Util
{
	public static function get_accept_foreign_tables()
	{
		return array();
	}

	public static function get_type4key($type_key = null, $is_return_bool = false)
	{
		if (is_numeric($type_key))
		{
			$types = static::get_types(true);
			if (in_array($type_key, $types)) return $type_key;

			if ($is_return_bool) return false;
			throw new \InvalidArgumentException('Parameter is invalid.');
		}

		if (!$type = \Config::get('message.types.'.$type_key))
		{
			if ($is_return_bool) return false;
			throw new \InvalidArgumentException('Parameter is invalid.');
		}

		return $type;
	}

	public static function get_key4type($target_type = null)
	{
		if (!is_numeric($target_type))
		{
			$type_keys = static::get_type_keys();
			if (in_array($target_type, $type_keys)) return $target_type;

			throw new \InvalidArgumentException('Parameter is invalid.');
		}

		$types = static::get_types();
		foreach ($types as $key => $type)
		{
			if ($type == $target_type) return $key;
		}

		throw new \InvalidArgumentException('Parameter is invalid.');
	}

	public static function check_type($target_type, $accept_type_keys)
	{
		if (!is_array($accept_type_keys)) $accept_type_keys = (array)$accept_type_keys;

		return in_array(self::get_key4type($target_type), $accept_type_keys);
	}

	public static function get_types($is_value_only = false, $is_admin_only = false)
	{
		$types = \Config::get('message.types');
		if ($is_admin_only)
		{
			$types = array(
				'site_info_all' => static::get_type4key('site_info_all'),
				'site_info' => static::get_type4key('site_info'),
				'system_info' => static::get_type4key('system_info'),
			);
		}

		return $is_value_only ? array_values($types) : $types;
	}

	public static function check_admin_type($target_type)
	{
		$admin_types = static::get_types(true, true);

		return in_array(static::get_type4key($target_type), $admin_types);
	}

	public static function get_type_keys()
	{
		return array_keys(\Config::get('message.types'));
	}

	public static function get_type_label($type, $is_simple = false)
	{
		$type_key = static::get_key4type($type);

		return term(sprintf('message.types.%s.%s', $is_simple ? 'labelSimple' : 'label', $type_key));
	}

	public static function get_talks4view($type_key = null, $related_id = 0, $params = array(), $self_member_id = 0, $member_ids = array(), $update_read_status = false)
	{
		list($list, $next_id) = Site_Model::get_talks(
			$type_key,
			$related_id,
			$params['max_id'],
			$params['limit'],
			$params['is_latest'],
			$params['is_desc'],
			$params['since_id']
		);
		$data = array(
			'list' => $list,
			'next_id' => $next_id,
			'since_id' => $params['since_id'] ?: 0,
			'is_display_load_before_link' => $params['max_id'] ? true : false,
			'unread_message_ids' => Site_Model::get_unread_message_ids($type_key, $list, $self_member_id, $member_ids),
		);

		return $data;
	}

	public static function get_no_data_talks()
	{
		return term('message.talks.view').'がありません。';
	}

	public static function get_detail_page_uri($type, $related_id, $message_id, $member_id_from)
	{
		switch ($type_key = Site_Util::get_key4type($type))
		{
			case 'member':
				return 'message/member/'.$member_id_from;
				break;
			case 'group':
				return 'message/group/'.$related_id;
				break;
		}

		return 'message/'.$message_id;
	}

	public static function change_all_status2read4member_id($member_id)
	{
		$changed_count = static::change_all_status2read4member_id_each('message_recieved', $member_id);
		$changed_count_summary = static::change_all_status2read4member_id_each('message_recieved_summary', $member_id);
		if (!$changed_count) $changed_count = $changed_count_summary;
		if ($changed_count) \Site_Notification::delete_unread_count_cache('message', $member_id);

		return $changed_count;
	}

	public static function change_all_status2read4member_id_each($table, $member_id)
	{
		if (!in_array($table, array('message_recieved', 'message_recieved_summary')))
		{
			throw new InvalidArgumentException('First parameter is invalid.');
		}
		$model = \Site_Model::get_model_name($table);

		$changed_count = 0;
		if (!$objs = $model::get4member_id($member_id, false)) return $changed_count;

		foreach ($objs as $obj)
		{
			if ($obj->update_status(true)) $changed_count++;
		}

		return $changed_count;
	}
}

