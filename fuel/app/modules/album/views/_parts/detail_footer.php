<?php echo Asset::js('bootstrap-carousel.js');?>
<?php echo Asset::js('jquery.masonry.min.js');?>
<?php echo Asset::js('jquery.infinitescroll.min.js');?>
<script type="text/javascript">
$('.carousel').carousel({
	interval: false
})

$(function(){
	var $container = $('#ai_container');
	$container.imagesLoaded(function(){
		$container.masonry({
			itemSelector : '.ai_item'
		});

		$container.infinitescroll({
			navSelector  : '#page-nav',   // ページのナビゲーションを選択
			nextSelector : '#page-nav a', // 次ページへのリンク
			itemSelector : '.ai_item',    // 持ってくる要素のclass
			loading: {
				finishedMsg: '<?php echo \Config::get('album.term.album_image'); ?>がありません。', //次のページがない場合に表示するテキスト
				img: '<?php echo \Uri::create('assets/img/site/loading_l.gif'); ?>' //ローディング画像のパス
			}
		},
		function( newElements ) {
			var $newElems = $( newElements ).css({ opacity: 0 });
			$newElems.imagesLoaded(function(){
				$newElems.animate({ opacity: 1 });
				$container.masonry( 'appended', $newElems, true );
			});
		});

	});
});

$('.commentBox').hover(
	function() {
		var id = $(this).attr('id').replace($(this).attr('class') + '_', '');
		var btn = '#btn_album_image_comment_delete_' + id;
		$(btn).show();
	},
	function() {
		var id = $(this).attr('id').replace($(this).attr('class') + '_', '');
		var btn = '#btn_album_image_comment_delete_' + id;
		$(btn).hide();
	}
);

$('.imgBox').hover(
	function() {
		var id = $(this).attr('id').replace($(this).attr('class') + '_', '');
		var btn = '#btn_album_image_edit_' + id;
		$(btn).show();
	},
	function() {
		var id = $(this).attr('id').replace($(this).attr('class') + '_', '');
		var btn = '#btn_album_image_edit_' + id;
		$(btn).hide();
	}
);

function set_cover(album_image_id) {
	var baseUrl = '<?php echo Uri::base(false); ?>';
	$.ajax({
		url : baseUrl + 'album/image/api/set_cover.json',
		dataType : 'text',
		data : {'id': album_image_id, '<?php echo Config::get('security.csrf_token_key'); ?>': '<?php echo Util_security::get_csrf(); ?>'},
		type : 'POST',
		success: function(status_after){
			$.jGrowl('カバー写真を設定しました。');
		},
		error: function(){
			$.jGrowl('カバー写真の設定に失敗しました。');
		}
	});
}
</script>