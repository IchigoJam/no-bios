; -----------------------------------------------------------------------------
;	ワークエリア
; -----------------------------------------------------------------------------
play_sound_effect_active:
		db		0				; 効果音再生中は 1
play_sound_effect_wait_count:
		db		0				; 効果音の待機時間
play_sound_effect_freq:
		dw		0				; 効果音の再生周波数
play_sound_effect_noise_freq:
		db		0				; 効果音のノイズ周波数
play_sound_effect_volume:
		db		0				; 効果音の音量
play_sound_effect_adr:
		dw		0				; 再生中の効果音データのアドレス
play_sound_effect_priority:
		db		255				; 再生中の効果音のプライオリティ [0が最高]

play_noise_freq:
		db		0				; 実際に再生するノイズ周波数決定用作業変数

play_bgm_data_adr:
		dw		0				; 再生中の BGMデータ先頭アドレス

play_master_volume_wait:
		db		0				; フェードアウト用待機時間
play_master_volume_speed:
		db		0				; フェードアウト用待機時間初期値[0はフェードアウト停止中]
play_master_volume:
		db		0				; マスター音量[0が最大音量, 15が無音]

play_drum_font1:
		dw		0				; ドラム音１の音色データアドレス
play_drum_font2:
		dw		0				; ドラム音２の音色データアドレス
play_drum_font3:
		dw		0				; ドラム音３の音色データアドレス
play_drum_font4:
		dw		0				; ドラム音４の音色データアドレス
play_drum_font5:
		dw		0				; ドラム音５の音色データアドレス

play_info_ch0:
		repeat i, INFO_SIZE
			db		0			; ch0 の演奏データ情報
		endr
play_info_ch1:
		repeat i, INFO_SIZE
			db		0			; ch1 の演奏データ情報
		endr
play_info_ch2:
		repeat i, INFO_SIZE
			db		0			; ch2 の演奏データ情報
		endr
