$('textarea.autogrow').autogrow();

function get_id_from_url()
{
	var is_parseInt = (arguments.length > 0) ? arguments[0] : true;

	var id = url('-1');
	if (is_parseInt) id = parseInt(id);

	return id;
}

function get_id_num(id_string)
{
	if (typeof id_string === "undefined") return false;

	var matches = id_string.match(/^[a-z0-9_]+_(\d+)$/i);
	if (matches) return matches[1];

	return false;
}

function get_url(uri)
{
	return get_baseUrl() + uri;
}

function set_token()
{
	var obj = (arguments.length > 0) ? arguments[0] : false;
	var token_key = get_token_key();

	if (obj == false) {
		return token_key + '=' + get_token();
	} else {
		obj[token_key] = get_token();
		return obj;
	}
}

function get_loading_image_tag()
{
	return '<img src="' + get_baseUrl() + 'assets/img/loading.gif' + '">';
}

function redirect(uri)
{
	location.href = get_url(uri);
}

function get_error_message(status)
{
	var default_message = (arguments.length > 1) ? arguments[1] : '';

	switch (status)
	{
		case 401:
			return '認証情報の取得に失敗しました。ログイン後、再度実行してください。';
		default :
			return default_message;
	}
}

function show_list(uri, list_block_id) {
	var record_limit         = (arguments.length > 2 && arguments[2]) ? arguments[2] : 0;
	var next_element_id_name = (arguments.length > 3 && arguments[3]) ? arguments[3] : '';
	var is_insert_before     = (arguments.length > 4 && arguments[4]) ? arguments[4] : false;
	var selfDomElement       = (arguments.length > 5) ? arguments[5] : false;

	if (!selfDomElement) {
		$(list_block_id).append('<div class="loading_image" id="list_loading_image">' + get_loading_image_tag() + '</div>');
	}

	var baseUrl = get_baseUrl();
	var get_url = baseUrl + uri;
	var get_data = {};
	get_data['nochache']  = (new Date()).getTime();
	get_data['disp_more'] = 0;
	if (record_limit > 0) {
		get_data['limit'] = record_limit;
		get_data['disp_more'] = 1;
	}

	var next_element_id_num  = (next_element_id_name.length > 0) ? get_id_num(next_element_id_name) : 0;
	if (next_element_id_num) {
		var key = (is_insert_before)? 'after_id' : 'before_id';
		get_data[key] = next_element_id_num;
	}

	$.ajax({
		url : get_url,
		type : 'GET',
		dataType : 'text',
		data : get_data,
		timeout: 10000,
		beforeSend: function(xhr, settings) {
			GL.execute_flg = true;
			if (selfDomElement) {
				$(selfDomElement).html(get_loading_image_tag());
			}
		},
		complete: function(xhr, textStatus) {
			GL.execute_flg = false;
		},
		success: function(result){
			if (selfDomElement) $(selfDomElement).remove();
			if (next_element_id_num) {
				if (is_insert_before) {
					$(list_block_id).prepend(result).fadeIn('fast');
				} else {
					$(list_block_id).append(result).fadeIn('fast');
				}
			} else {
				$(list_block_id).html(result).fadeIn('fast');
			}
		},
		error: function(result) {
			$.jGrowl(get_error_message(result['status'], '読み込みに失敗しました。'));
		}
	});

	if (!selfDomElement) $('#list_loading_image').remove();
}

function delete_item(uri)
{
	var id = (arguments.length > 1) ? arguments[1] : 0;
	var target_attribute_prefix = (arguments.length > 2) ? arguments[2] : '';
	var item_term = (arguments.length > 3) ? arguments[3] : '';

	apprise('削除しますか?', {'confirm':true}, function(r) {
		if (id > 0 && target_attribute_prefix.length > 0) {
			if (r == true) delete_item_execute_ajax(uri, id, target_attribute_prefix, item_term);
		} else {
			if (r == true) delete_item_execute(uri);
		}
	});
}

function delete_item_execute(uri)
{
	var url = get_url(uri) + '?' + set_token();
	location.href = url;
}

function delete_item_execute_ajax(post_uri, id, target_attribute_prefix, item_term)
{
	var baseUrl = get_baseUrl();

	var token_key = get_token_key();
	var post_data = {};
	post_data['id'] = id;
	post_data[token_key] = get_token();

	var msg_prefix = '';
	if (item_term.length > 0) msg_prefix = item_term + 'を';

	$.ajax({
		url : baseUrl + post_uri,
		dataType : "text",
		data : post_data,
		type : 'POST',
		success: function(data){
			$(target_attribute_prefix + '_' + id).fadeOut();
			$.jGrowl(msg_prefix + '削除しました。');
		},
		error: function(data){
			$.jGrowl(get_error_message(data['status'], msg_prefix + '削除できませんでした。'));
		}
	});
}

function reset_textarea()
{
	var textarea_attribute = (arguments.length > 0) ? arguments[0] : 'textarea';
	var textarea_height    = (arguments.length > 1) ? arguments[1] : '33px';

	$(textarea_attribute).val('');
	$(textarea_attribute).css('height', textarea_height);
}

function create_comment(parent_id, post_uri, get_uri, before_element_id_name)
{
	var selfDomElement     = (arguments.length > 4) ? arguments[4] : false;
	var textarea_attribute = (arguments.length > 5) ? arguments[5] : '#textarea_comment';
	var list_block_id      = (arguments.length > 6) ? arguments[6] : '#comment_list';
	var textarea_height    = (arguments.length > 7) ? arguments[7] : '33px';

	var body = $(textarea_attribute).val().trim();
	if (body.length <= 0) return;

	var selfDomElement_html = (selfDomElement) ? $(selfDomElement).html() : '';
	var data = {'id':parent_id, 'body':body};
	data = set_token(data);
	$.ajax({
		url : get_baseUrl() + post_uri,
		type : 'POST',
		dataType : 'text',
		data : data,
		timeout: 10000,
		beforeSend: function(xhr, settings) {
			GL.execute_flg = true;
			if (selfDomElement) {
				$(selfDomElement).attr('disabled', true);
				$(selfDomElement).html(get_loading_image_tag());
			}
		},
		complete: function(xhr, textStatus) {
			GL.execute_flg = false;
			if (selfDomElement) {
				$(selfDomElement).attr('disabled', false);
				$(selfDomElement).html(selfDomElement_html);
			}
		},
		success: function(result){
			$.jGrowl('コメントを投稿しました。');
			show_list(get_uri, list_block_id, 0, before_element_id_name);
			$(textarea_attribute).val('');
			$(textarea_attribute).css('height', textarea_height);
		},
		error: function(data){
			$.jGrowl(get_error_message(data['status'], 'コメントを投稿できませんでした。'));
		}
	});
}

function set_datetimepicker(attribute)
{
	$(attribute).datetimepicker({
		dateFormat: 'yy-mm-dd',
		maxDate: 0,
		changeYear: true,
		changeMonth: true,
		prevText: '&#x3c;前',
		nextText: '次&#x3e;',
		timeFormat: 'hh:mm',
		hourGrid: 6,
		minuteGrid: 15,
		addSliderAccess: true,
		sliderAccessArgs: { touchonly: false }
	});
}