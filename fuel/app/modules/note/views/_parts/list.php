<?php if ($list): ?>
<div id="article_list">
<?php foreach ($list as $id => $note): ?>
	<div class="article">
		<div class="header">
			<h4><?php echo Html::anchor('note/detail/'.$id, $note->title); ?></h4>

			<div class="member_img_box_s">
				<?php echo img($note->member->file->name, '30x30', 'member/'.$note->member_id); ?>
				<div class="content">
					<div class="main">
						<b class="fullname"><?php echo Html::anchor('member/'.$note->member_id, $note->member->name); ?></b>
					</div>
					<small><?php echo site_get_time($note->created_at); ?></small>
				</div>
			</div>
		</div>
		<div class="body"><?php echo nl2br(mb_strimwidth($note->body, 0, Config::get('note.article_list.trim_width'), '...')) ?></div>
	</div>
<?php endforeach; ?>
</div>
<?php else: ?>
<?php echo \Config::get('site.term.note'); ?>がありません。
<?php endif; ?>