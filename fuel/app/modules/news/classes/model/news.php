<?php
namespace News;

class Model_News extends \Orm\Model
{
	protected static $_table_name = 'news';

	protected static $_belongs_to = array(
		'users' => array(
			'key_from' => 'users_id',
			'model_to' => '\Admin\Model_User',
			'key_to' => 'id',
			'cascade_save' => true,
			'cascade_delete' => false,
		),
	);
	protected static $_has_one = array(
		'news_category' => array(
			'key_from' => 'news_category_id',
			'model_to' => '\News\Model_NewsCategory',
			'key_to' => 'id',
			'cascade_save' => true,
			'cascade_delete' => false,
		)
	);
	protected static $_has_many = array(
		'news_image' => array(
			'key_from' => 'id',
			'model_to' => '\News\Model_NewsImage',
			'key_to' => 'news_id',
		)
	);

	protected static $_properties = array(
		'id',
		'news_category_id' => array(
			'data_type' => 'integer',
			'label' => 'ニュースカテゴリ',
			'validation' => array('valid_string' => array('numeric')),
			'form' => array('type' => 'select'),
		),
		'title' => array(
			'data_type' => 'varchar',
			'label' => 'タイトル',
			'validation' => array('trim', 'required', 'max_length' => array(255)),
			'form' => array('type' => 'text'),
		),
		'body' => array(
			'data_type' => 'text',
			'label' => '本文',
			'validation' => array('trim', 'required'),
			'form' => array('type' => 'textarea', 'rows' => 10),
		),
		'is_published' => array(
			'data_type' => 'integer',
			'validation' => array('in_array' => array(array(0,1))),
			'form' => array('type' => false),
		),
		'published_at' => array(
			'data_type' => 'datetime',
			'label' => '公開日時',
			'validation' => array('trim', 'valid_date' => array('Y-m-d H:i:s')),
			'form' => array('type' => 'text'),
		),
		'users_id' => array(
			'data_type' => 'integer',
			'form' => array('type' => false),
		),
		'token' => array(
			'data_type' => 'varchar',
			'form' => array('type' => false),
			'validation' => array('trim', 'max_length' => array(255)),
		),
		'created_at' => array('form' => array('type' => false)),
		'updated_at' => array('form' => array('type' => false)),
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
	);

	public static function _init()
	{
		//if (\Config::get('news.category.isEnabled'))
		//{
		//	$news_category_id_options = array();
		//	static::$_properties['news_category_id']['form']['options'] = $news_category_id_options;
		//	static::$_properties['news_category_id']['validation']['in_array'][] = array_keys($news_category_id_options);
		//}
		//else
		//{
		//	static::$_properties['news_category_id']['form']['type'] = false;
		//}
	}

	public static function check_authority($id)
	{
		if (!$id) return false;
		if (!$obj = self::find($id)) return false;

		return $obj;
	}

	public function delete_with_relations()
	{
		// news_image の削除
		list($result, $deleted_files) = Model_NewsImage::delete_multiple4news_id($this->id);

		//// timeline 投稿の削除
		//if (\Module::loaded('timeline')) \Timeline\Model_Timeline::delete4foreign_table_and_foreign_ids('news', $this->id);

		// note の削除
		$this->delete();

		return $deleted_files;
	}
}