<?php
namespace Album;

class Model_AlbumImage extends \Orm\Model
{
	protected static $_table_name = 'album_image';

	protected static $_belongs_to = array(
		'album' => array(
			'key_from' => 'album_id',
			'model_to' => '\Album\Model_Album',
			'key_to' => 'id',
			'cascade_save' => false,
			'cascade_delete' => false,
		),
	);
	protected static $_has_one = array(
		'file' => array(
			'key_from' => 'file_id',
			'model_to' => '\Model_File',
			'key_to' => 'id',
			'cascade_save' => false,
			'cascade_delete' => true,
		),
	);
	protected static $_has_many = array(
		'album_image_comment' => array(
			'key_from' => 'id',
			'model_to' => '\Album\Model_AlbumImageComment',
			'key_to' => 'album_image_id',
			'cascade_save' => false,
			'cascade_delete' => false,
		)
	);

	protected static $_properties = array(
		'id',
		'album_id',
		'file_id' => array(
			'validation' => array(
				'trim',
				'required',
				'valid_string' => array('integer'),
			),
		),
		'name',
		'created_at',
		'updated_at',
	);

	protected static $_observers = array(
		'Orm\Observer_CreatedAt' => array(
			'events' => array('before_insert'),
			'mysql_timestamp' => true,
		),
		'Orm\Observer_UpdatedAt' => array(
			'events' => array('before_save'),
			'mysql_timestamp' => true,
		),
	);

	protected static $count_par_album_list = array();

	public static function validate($factory)
	{
		$val = \Validation::forge($factory);

		return $val;
	}

	public static function check_authority($id, $target_member_id = 0, $with_file = true)
	{
		if (!$id) return false;

		$obj = self::find()->where('id', $id)->related('album')->get_one();
		if (!$obj) return false;
		if ($target_member_id && $target_member_id != $obj->album->member_id) return false;

		if ($with_file) $obj->file = \Model_File::find($obj->file_id);

		return $obj;
	}

	public function get_image()
	{
		if (empty($this->file_id)) return '';

		return \Model_File::get_name($this->file_id);
	}

	public static function delete_with_file($id)
	{
		if (!$id || !$album_image = self::find()->where('id', $id)->related('album')->get_one())
		{
			throw new \Exception('Invalid album_image id.');
		}

		if ($album_image->album->cover_album_image_id == $id)
		{
			$album_image->album->cover_album_image_id = null;
			$album_image->album->save();
		}

		$album_id = $album_image->album_id;
		$album_image->file = \Model_File::find($album_image->file_id);
		$file_name = $album_image->file->name;
		$filesize = $album_image->file->filesize;
		$album_image->file->delete();
		$album_image->delete();
		\Site_util::remove_images('ai', $album_id, $file_name);

		return $filesize;
	}

	public static function get_count4album_id($album_id)
	{
		if (!empty(self::$count_par_album_list[$album_id])) return self::$count_par_album_list[$album_id];

		$query = self::find()->where('album_id', $album_id);
		self::$count_par_album_list[$album_id] = $query->count();

		return self::$count_par_album_list[$album_id];
	}
}