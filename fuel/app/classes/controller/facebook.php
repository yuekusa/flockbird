<?php
require_once APPPATH.'vendor/facebook-php-sdk/facebook.php';

class Controller_Facebook extends Controller_Site
{
	private $fb;

	public function before()
	{
		parent::before();
		if (!PRJ_FACEBOOK_APP_ID) throw new HttpNotFoundException;

		Config::load('facebook', 'facebook');
		$this->fb = new Facebook(Config::get('facebook.init'));
	}

//	public function action_index()
//	{
//		$this->template->title = 'Index » Index';
//
//		$is_login = $this->fb->getUser()?true:false;
//		$data = array(
//			'is_login' => $is_login,
//		);
//
//		if($is_login and Input::method() == 'POST')
//		{
//			$v = Validation::forge();
//			$v->add('message', 'message')->add_rule('required');
//			if(!$v->run())
//			{
//				Session::set_flash('message', $v->error('message')->get_message());
//			}
//			else
//			{
//				$message = $v->validated('message');
//				try
//				{
//					$res = $this->fb->api(array(
//						'method' => 'stream.publish',
//						'message' => $message,
//					));
//					Session::set_flash('message', 'complete!!');
//				}
//				catch (FacebookApiException $e)
//				{
//					Session::set_flash('message', $e->getMessage());
//				}
//				Response::redirect('facebook/index/');
//			}
//		}
//
//		$this->template->content = View::forge('facebook/index',$data);
//	}

	public function action_login()
	{
		$url = $this->fb->getLoginUrl(Config::get('facebook.login'));
		Response::redirect($url);
	}

	public function action_callback()
	{
		try
		{
			$fb = $this->fb->api('/me');
			$is_save = false;
			if (!$user = Model_MemberFacebook::find_by_facebook_id($fb['id']))
			{
				$member_id = $this->create_member_from_facebook($fb['id'], $fb['name']);
				$user = new Model_MemberFacebook;
				$user->member_id = $member_id;
				$user->facebook_id   = $fb['id'];
				$user->facebook_name = $fb['name'];
				$user->facebook_link = $fb['link'];
				if ($image = $this->save_profile_image($user->member_id, $user->facebook_id))
				{
					$member = Model_Member::find()->where('id', $user->member_id)->get_one();
					$member->image = $image;
				}
				$is_save = true;
			}
			else
			{
				if ($user->facebook_name != $fb['name'])
				{
					$user->facebook_name = $fb['name'];
					$is_save = true;
				}
				if ($user->facebook_link != $fb['link'])
				{
					$user->facebook_link = $fb['link'];
					$is_save = true;
				}
				if ($image = $this->save_profile_image($user->member_id, $user->facebook_id, $user->member->image))
				{
					$member = Model_Member::find()->where('id', $user->member_id)->get_one();
					$member->image = $image;
					$is_save = true;
				}
			}
			if ($is_save)
			{
				$user->save();
				if (!empty($image)) $member->save();
			}
			$this->login($user->member_id);
			Session::set_flash('message', 'ログインしました');
			Response::redirect('member');
		}
		catch (Orm\ValidationFailed $e)
		{
			throw new Exception($e->getMessage());
		}
		catch (FacebookApiException $e)
		{
			throw new Exception($e->getMessage());
		}
		catch (Exception $e)
		{
			throw new Exception($e->getMessage());
		}
	}

	public function action_logout()
	{
		$url = $this->fb->getLogoutUrl(Config::get('facebook.logout'));
		$this->fb->destroySession();
		Auth::logout();
		Session::set_flash('message', 'ログアウトしました');
		Response::redirect($url);
	}

	private function create_member_from_facebook($facebook_id, $name)
	{
		if (!$member_id = Model_Member::create_member_from_facebook($facebook_id, $name))
		{
			throw new Exception('Create member failed.');
		}

		return $member_id;
	}

	private function login($member_id)
	{
		$auth = Auth::instance();
		$auth->logout();
		if (!$auth->force_login($member_id))
		{
			throw new Exception('Member login failed.');
		}

		return true;
	}

	private function save_profile_image($member_id, $facebook_id, $old_filename = '')
	{
		$image_url = 'http://graph.facebook.com/'.$facebook_id.'/picture?type=large';
		if (!$data = file_get_contents($image_url)) throw new Exception($eception_message);

		$original_filepath = Config::get('site.image.member.original.path');
		if ($old_filename)
		{
			$old_data = file_get_contents($original_filepath.'/'.$old_filename);
			if ($data == $old_data) return false;

			unset($old_data);
		}

		$tmp_filename = Util_string::get_random();
		$tmp_file = PRJ_UPLOAD_DIR.'/img/tmp/'.$tmp_filename;
		file_put_contents($tmp_file, $data);
		if (!$extension = Util_file::get_image_type($tmp_file))
		{
			throw new Exception('Failed to save profile image.');
		}

		$filename = Util_file::make_filename($tmp_filename, $extension, 'm_'.$member_id);
		Util_file::move($tmp_file, $original_filepath.'/'.$filename);

		if (!Util_file::make_thumbnails($original_filepath, $filename, Config::get('site.image.member'), 'original', $old_filename))
		{
			throw new Exception('Resize error.');
		}

		return $filename;
	}
}