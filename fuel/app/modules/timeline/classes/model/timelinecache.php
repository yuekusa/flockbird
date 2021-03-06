<?php
namespace Timeline;

class Model_TimelineCache extends \MyOrm\Model
{
	protected static $_table_name = 'timeline_cache';

	protected static $_belongs_to = array(
		'timeline' => array(
			'key_from' => 'timeline_id',
			'model_to' => '\Timeline\Model_Timeline',
			'key_to' => 'id',
		),
	);

	protected static $_properties = array(
		'id',
		'timeline_id' => array(
			'data_type' => 'integer',
			'form' => array('type' => false),
		),
		'member_id' => array(
			'data_type' => 'integer',
			'form' => array('type' => false),
		),
		'member_id_to' => array(
			'data_type' => 'integer',
			'form' => array('type' => false),
		),
		'group_id' => array(
			'data_type' => 'integer',
			'form' => array('type' => false),
		),
		'page_id' => array(
			'data_type' => 'integer',
			'form' => array('type' => false),
		),
		'is_follow' => array(
			'data_type' => 'integer',
			'validation' => array('max_length' => array(1), 'in_array' => array(array(0,1))),
			'form' => array('type' => false),
			'default' => 0,
		),
		'public_flag' => array(
			'data_type' => 'integer',
			'validation' => array('required', 'max_length' => array(2)),
			'form' => array(),
		),
		'type' => array(
			'data_type' => 'integer',
			'validation' => array('max_length' => array(2)),
			'form' => array('type' => false),
		),
		'comment_count' => array(
			'data_type' => 'integer',
			'default' => 0,
			'form' => array('type' => false),
		),
		'like_count' => array(
			'data_type' => 'integer',
			'default' => 0,
			'form' => array('type' => false),
		),
		'importance_level' => array(
			'data_type' => 'integer',
			'default' => 0,
			'validation' => array('required', 'max_length' => array(2)),
			'form' => array('type' => false),
		),
	);

	protected static $_observers = array(
		'Orm\Observer_Validation' => array(
			'events' => array('before_save')
		),
	);

	public static function _init()
	{
		static::$_properties['type']['validation']['in_array'][] = \Config::get('timeline.types');

		static::$_properties['public_flag']['form'] = \Site_Form::get_public_flag_configs();
		static::$_properties['public_flag']['validation']['in_array'][] = \Site_Util::get_public_flags();
	}

	public static function get4timeline_id($timeline_id, $is_limit_one_record = false, $is_follow = false)
	{
		$query = self::query()->where('timeline_id', $timeline_id);
		if (!$is_limit_one_record) return $query->get();

		return $query->where('is_follow', (int)$is_follow)->get_one();
	}
}
