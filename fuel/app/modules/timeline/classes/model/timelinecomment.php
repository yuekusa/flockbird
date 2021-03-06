<?php
namespace Timeline;

class Model_TimelineComment extends \MyOrm\Model
{
	protected static $_table_name = 'timeline_comment';

	protected static $_belongs_to = array(
		'timeline' => array(
			'key_from' => 'timeline_id',
			'model_to' => '\Timeline\Model_Timeline',
			'key_to' => 'id',
		),
		'member' => array(
			'key_from' => 'member_id',
			'model_to' => 'Model_Member',
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
		'body' => array(
			'data_type' => 'varchar',
			'form' => array('type' => false),
		),
		'like_count' => array(
			'data_type' => 'integer',
			'default' => 0,
			'form' => array('type' => false),
		),
		'created_at',
		'updated_at',
	);

	protected static $_observers = array(
		'Orm\Observer_Validation' => array(
			'events' => array('before_save'),
		),
		'Orm\Observer_CreatedAt' => array(
			'events' => array('before_insert'),
			'mysql_timestamp' => true,
		),
		'Orm\Observer_UpdatedAt' => array(
			'events' => array('before_save'),
			'mysql_timestamp' => true,
		),
		'MyOrm\Observer_CountUpToRelations' => array(
			'events'   => array('after_insert'),
			'relations' => array(
				array(
					'model_to' => '\Timeline\Model_Timeline',
					'conditions' => array('id' => array('timeline_id' => 'property'),
					),
					//'optional_updates' => array(
					//	'sort_datetime' => array(
					//		'created_at' => 'property',
					//	),
					//),
				),
			),
		),
		'MyOrm\Observer_CountDownToRelations'=>array(
			'events'   => array('after_delete'),
			'relations' => array(
				array(
					'model_to' => '\Timeline\Model_Timeline',
					'conditions' => array(
						'id' => array(
							'timeline_id' => 'property',
						),
					),
				),
			),
		),
		'MyOrm\Observer_InsertRelationialTable'=>array(
			'events'   => array('after_insert'),
			'model_to' => '\Timeline\Model_MemberFollowTimeline',
			'properties' => array(
				'timeline_id' => 'timeline_id',
				'member_id',
			),
			'is_check_duplicated' => array(
				'conditions' => array(
					'timeline_id' => 'timeline_id',
					'member_id',
				),
			),
		),
	);

	protected static $count_per_timeline = array();

	public static function _init()
	{
		if (is_enabled('notice'))
		{
			static::$_observers['MyOrm\Observer_InsertNotice'] = array(
				'events'   => array('after_insert'),
				'update_properties' => array(
					'foreign_table' => array('timeline' => 'value'),
					'foreign_id' => array('timeline_id' => 'property'),
					'type_key' => array('comment' => 'value'),
					'member_id_from' => array('member_id' => 'property'),
					'member_id_to' => array(
						'related' => array('timeline' => 'member_id'),
					),
				),
			);
			$type = \Notice\Site_Util::get_notice_type('comment');
			static::$_observers['MyOrm\Observer_DeleteNotice'] = array(
				'events' => array('before_delete'),
				'conditions' => array(
					'foreign_table' => array('timeline' => 'value'),
					'foreign_id' => array('timeline_id' => 'property'),
					'type' => array($type => 'value'),
				),
			);
		}
	}

	public static function check_authority($id, $target_member_id = 0, $related_tables = null, $member_id_prop = 'member_id', $parent_table_with_member_id = null)
	{
		if (is_null($related_tables)) $related_tables = array('timeline');

		$id = (int)$id;
		if (!$id) throw new \HttpNotFoundException;

		$params = array('rows_limit' => 1);
		if ($related_tables) $params['related'] = $related_tables;
		if (!$obj = self::find($id, $params)) throw new \HttpNotFoundException;

		$accept_member_ids = array($obj->{$member_id_prop}, $obj->timeline->{$member_id_prop});
		if ($target_member_id && !in_array($target_member_id, $accept_member_ids))
		{
			throw new \HttpForbiddenException;
		}

		return $obj;
	}

	public static function get_count4timeline_id($timeline_id)
	{
		if (!empty(self::$count_per_timeline[$timeline_id])) return self::$count_per_timeline[$timeline_id];

		$query = self::query()->select('id')->where('timeline_id', $timeline_id);
		self::$count_per_timeline[$timeline_id] = $query->count();

		return self::$count_per_timeline[$timeline_id];
	}
}
