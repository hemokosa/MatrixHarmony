// ============================================================
// MatrixHarmonyLib - 音響和声ライブコーディングライブラリ
// ============================================================
//
// 使い方:
//   1. このファイル全体を評価する (Cmd+Shift+Enter)
//   2. m.boot で起動
//   3. ~out = m.matrix で64本SinOscマトリクスを定義
//   4. m.send(~out, ...) でパラメータを設定
//
// ライブラリは解釈変数 m に格納される。
// ProxySpace を push した後も m.xxx でアクセスできる。
// ============================================================
(
m = m ? ();
m.know = true;

// -----------------------------------------------------------
// 音程比(純正律)
// -----------------------------------------------------------
m.unison     = 1;
m.minor2     = 16/15;   // 短2度
m.smallWhole = 10/9;    // 小全音
m.major2     = 9/8;     // 長2度
m.minor3     = 6/5;     // 短3度
m.major3     = 5/4;     // 長3度
m.perfect4   = 4/3;     // 完全4度
m.aug4       = 45/32;   // 増4度
m.dim5       = 64/45;   // 減5度
m.perfect5   = 3/2;     // 完全5度
m.minor6     = 8/5;     // 短6度
m.major6     = 5/3;     // 長6度
m.natural7   = 7/4;     // 自然7度
m.minor7     = 16/9;    // 短7度
m.major7     = 15/8;    // 長7度
m.octave     = 2;       // オクターブ

// 音程グループ
m.allIntervals = [16/15, 10/9, 9/8, 6/5, 5/4, 4/3, 45/32, 64/45, 3/2, 8/5, 5/3, 7/4, 16/9, 15/8];
m.consonant    = [6/5, 5/4, 3/2, 8/5, 5/3];
m.dissonant    = [16/15, 9/8, 16/9, 15/8];
m.seconds      = [16/15, 10/9, 9/8];
m.thirds       = [6/5, 5/4];
m.fourths      = [4/3, 45/32];
m.fifths       = [64/45, 3/2];
m.sixths       = [8/5, 5/3];
m.sevenths     = [7/4, 16/9, 15/8];

// 和音テンプレート
m.majorTriad = [1, 5/4, 3/2];
m.minorTriad = [1, 6/5, 3/2];
m.dom7  = [1, 5/4, 3/2, 16/9];
m.maj7  = [1, 5/4, 3/2, 15/8];
m.min7  = [1, 6/5, 3/2, 16/9];

// ドミナント・モーション用
m.semitoneUp   = 16/15;
m.semitoneDown = 15/16;
m.dominantRatios = [15/16, 16/15];

// n平均律
m.et = { |self, n=12| 2 ** (1/n) };

// -----------------------------------------------------------
// 周波数配列
// -----------------------------------------------------------

// 倍音列(等差数列)
m.harm = { |self, n=8, start=1, step=1|
	Array.series(n, start, step)
};

// 下方倍音列
m.subharm = { |self, n=8|
	Array.series(n, 1, 1).reciprocal
};

// 音程列(等比数列)
m.intv = { |self, n=8, ratio=1.5, start=1|
	Array.geom(n, start, ratio)
};

// ランダムな音程連鎖(累積積)
m.chain = { |self, n=8, pool|
	var arr = Array.fill(n, 1.0);
	pool = pool ?? { [6/5, 5/4] };
	(n-1).do { |i| arr[i+1] = arr[i] * pool.choose };
	arr
};

// ランダムな下行音程連鎖
m.chainDown = { |self, n=8, pool|
	var arr = Array.fill(n, 1.0);
	pool = pool ?? { [5/6, 4/5, 2/3] };
	(n-1).do { |i| arr[i+1] = arr[i] * pool.choose };
	arr
};

// -----------------------------------------------------------
// 振幅配列
// -----------------------------------------------------------

// 一定振幅
m.ampFlat = { |self, n=64|
	Array.fill(n, 1).normalizeSum
};

// 倍音次数に反比例(nH x nI マトリクス)
m.ampInv = { |self, nH=8, nI=8|
	(Array.series(nH, 1, 1).reciprocal *.x Array.fill(nI, 1)).normalizeSum
};

// 倍音次数に反比例(逆順=高次倍音強調)
m.ampInvRev = { |self, nH=8, nI=8|
	(Array.series(nH, 1, 1).reciprocal *.x Array.fill(nI, 1)).reverse.normalizeSum
};

// 高域強調
m.ampProg = { |self, nH=8, nI=8|
	(Array.series(nH, 1, 1) *.x Array.series(nI, 1, 1)).normalizeSum
};

// 積の逆数(距離に反比例)
m.ampProdInv = { |self, nH=8, nI=8|
	(Array.series(nH, 1, 1) *.x Array.series(nI, 1, 1)).reciprocal.normalizeSum
};

// ランダム振幅(一様分布)
m.ampRand = { |self, n=64|
	Array.rand(n, 0.0, 1.0).normalizeSum
};

// ランダム振幅(指数分布)
m.ampExp = { |self, n=64|
	Array.exprand(n, 0.001, 1.0).normalizeSum
};

// 疎な振幅(部分集合)
m.ampSparse = { |self, n=64, density=0.3|
	(Array.rand(n, 0.0, 1.0) * Array.fill(n, {
		[0, 1].wchoose([1.0 - density, density])
	})).normalizeSum
};

// -----------------------------------------------------------
// パン配列
// -----------------------------------------------------------

m.panC = { |self, n=64| Array.fill(n, 0.0) };
m.panR = { |self, n=64| Array.rand2(n, 1.0) };

// -----------------------------------------------------------
// 変換
// -----------------------------------------------------------

// 音響ドミナント・シフト(各線を半音上下にずらす)
m.dominant = { |self, freqs, ratios|
	ratios = ratios ?? { [15/16, 16/15] };
	freqs * Array.fill(freqs.size, { ratios.choose })
};

// デチューン(ゆらぎ)
m.detune = { |self, freqs, amount=5.0|
	freqs + Array.rand2(freqs.size, amount)
};

// 振幅の間引き
m.thin = { |self, amps, keepRatio=0.5|
	(amps * Array.fill(amps.size, {
		[0.001, 1.0].wchoose([1.0 - keepRatio, keepRatio])
	})).normalizeSum
};

// 振幅の減衰
m.fade = { |self, amps, factor=0.5|
	(amps * Array.fill(amps.size, { [factor, 1.0].choose })).normalizeSum
};

// -----------------------------------------------------------
// シンセ関数(Functionを返す → ProxySpaceで ~out = m.xxx)
// -----------------------------------------------------------

// 16本の線(Klang): 音色探索用
m.line16 = { |self|
	{ |base=441, fscale=1, foffset=0, pan=0, level=0.8|
		var farray = Control.names(\farray).kr(Array.fill(16, 0)) * base;
		var aarray = Control.names(\aarray).kr(Array.fill(16, 1).normalizeSum);
		Pan2.ar(Klang.ar(`[farray, aarray, nil], fscale, foffset), pan, level)
	}
};

// 64本の線(SinOsc): マトリクス和音の基本
m.matrix = { |self|
	{ |base=441, level=0.8|
		var farray = Control.names(\farray).kr(Array.fill(64, 0));
		var aarray = Control.names(\aarray).kr(Array.fill(64, 0));
		var parray = Control.names(\parray).kr(Array.fill(64, 0));
		Mix.new(Pan2.ar(
			SinOsc.ar(farray * base, 0.0, aarray, 0.0),
			parray, level))
	}
};

// 64本 + 線形補間: 音響和声(和音遷移)用
m.interp = { |self|
	{ |dur=10, base1=441, base2=441, level=0.8|
		var fa1 = Control.names(\farray1).kr(Array.fill(64, 0));
		var fa2 = Control.names(\farray2).kr(Array.fill(64, 0));
		var aa1 = Control.names(\aarray1).kr(Array.fill(64, 0));
		var aa2 = Control.names(\aarray2).kr(Array.fill(64, 0));
		var pa1 = Control.names(\parray1).kr(Array.fill(64, 0));
		var pa2 = Control.names(\parray2).kr(Array.fill(64, 0));
		Mix.new(Pan2.ar(
			SinOsc.ar(
				Line.kr(fa1 * base1, fa2 * base2, dur), 0.0,
				Line.kr(aa1, aa2, dur), 0.0),
			Line.kr(pa1, pa2, dur), level))
	}
};

// 2 x 32本: ポリコード用
m.dual = { |self|
	{ |base1=441, base2=441, level=0.4|
		var fa1 = Control.names(\farray1).kr(Array.fill(32, 0));
		var fa2 = Control.names(\farray2).kr(Array.fill(32, 0));
		var aa1 = Control.names(\aarray1).kr(Array.fill(32, 0));
		var aa2 = Control.names(\aarray2).kr(Array.fill(32, 0));
		var pa1 = Control.names(\parray1).kr(Array.fill(32, 0));
		var pa2 = Control.names(\parray2).kr(Array.fill(32, 0));
		Mix.new(Pan2.ar(
			SinOsc.ar(
				(fa1 * base1) ++ (fa2 * base2), 0.0,
				aa1 ++ aa2, 0.0),
			pa1 ++ pa2, level))
	}
};

// 2 x 32本 + 線形補間: 二重和声進行用
m.dualInterp = { |self|
	{ |dur=10, base11=441, base12=441, base21=441, base22=441, level=0.4|
		var fa11 = Control.names(\farray11).kr(Array.fill(32, 0));
		var fa12 = Control.names(\farray12).kr(Array.fill(32, 0));
		var fa21 = Control.names(\farray21).kr(Array.fill(32, 0));
		var fa22 = Control.names(\farray22).kr(Array.fill(32, 0));
		var aa11 = Control.names(\aarray11).kr(Array.fill(32, 0));
		var aa12 = Control.names(\aarray12).kr(Array.fill(32, 0));
		var aa21 = Control.names(\aarray21).kr(Array.fill(32, 0));
		var aa22 = Control.names(\aarray22).kr(Array.fill(32, 0));
		var pa11 = Control.names(\parray11).kr(Array.fill(32, 0));
		var pa12 = Control.names(\parray12).kr(Array.fill(32, 0));
		var pa21 = Control.names(\parray21).kr(Array.fill(32, 0));
		var pa22 = Control.names(\parray22).kr(Array.fill(32, 0));
		var f1 = (fa11 * base11) ++ (fa21 * base21);
		var f2 = (fa12 * base12) ++ (fa22 * base22);
		Mix.new(Pan2.ar(
			SinOsc.ar(
				Line.kr(f1, f2, dur), 0.0,
				Line.kr(aa11 ++ aa21, aa12 ++ aa22, dur), 0.0),
			Line.kr(pa11 ++ pa21, pa12 ++ pa22, dur), level))
	}
};

// -----------------------------------------------------------
// セットアップ & トランスポート
// -----------------------------------------------------------

m.boot = { |self, fadeTime=1.0|
	var server = Server.default;
	server.options.numBuffers = 1024 * 32;
	server.options.memSize = 8192 * 32;
	server.options.maxNodes = 1024 * 64;
	server.options.numWireBufs = 1024 * 8;
	server.options.numOutputBusChannels = 2;
	server.options.numInputBusChannels = 2;
	server.recSampleFormat = "int16";
	server.recChannels = 2;
	if(server.serverRunning.not) { server.boot };
	p = ProxySpace.push(server);
	p.fadeTime = fadeTime;
	p.clock = TempoClock.default;
	"MatrixHarmony: ready".postln;
};

// パラメータ設定 + リビルド
m.send = { |self, proxy ... args|
	proxy.setn(*args).rebuild;
};

// 終了
m.finish = { |self, fadeOut=10|
	p !? { p.end(fadeOut); p.clear.pop; p.free };
	p = nil;
};

// -----------------------------------------------------------
// 連続補間(3つ以上のマトリクスを順に線形補間)
// -----------------------------------------------------------

// マトリクス列を順に補間するTaskProxyを返す
// proxy: interp シンセを割り当てた NodeProxy (~out = m.interp)
// specs: マトリクス仕様の配列。各要素は Event:
//   (base: 441, farray: [...], aarray: [...], parray: [...])
// dur: 各遷移の補間時間(秒)
// dt: 各遷移後の待機時間(秒、dur以上を推奨)
// repeat: true で無限ループ
//
// 使い方:
//   x = m.interpSeq(~out, specs, dur: 5, dt: 5);
//   x.play;  // 開始
//   x.stop;  // 停止
m.interpSeq = { |self, proxy, specs, dur=5, dt=5, repeat=true, level=0.4|
	var task = TaskProxy.new;
	task.source = {
		var n = specs.size;
		var doOnce = {
			(n - 1).do { |i|
				var s1 = specs[i];
				var s2 = specs[i + 1];
				self.send(proxy,
					\level, level, \dur, dur,
					\base1, s1[\base] ? 441,
					\base2, s2[\base] ? 441,
					\farray1, s1[\farray],
					\farray2, s2[\farray],
					\aarray1, s1[\aarray].normalizeSum,
					\aarray2, s2[\aarray].normalizeSum,
					\parray1, s1[\parray] ? Array.fill(64, 0.0),
					\parray2, s2[\parray] ? Array.fill(64, 0.0));
				dt.wait;
			};
		};
		if(repeat) { loop { doOnce.value } } { doOnce.value };
	};
	task
};

// -----------------------------------------------------------
// 保持音
// -----------------------------------------------------------

m.pedal = { |self, freq=8820, amp=0.1, key=\pedal|
	p[key] = { SinOsc.ar(freq.dup, 0, amp, 0) };
	p[key].play;
};

m.pedalPulse = { |self, freq=70, rate=10, amp=0.3, key=\pedal|
	p[key] = { SinOsc.ar(freq.dup, 0, LFPulse.kr(rate, 0, 0.5, amp), 0) };
	p[key].play;
};

m.pedalImpulse = { |self, rate=2, amp=0.5, key=\pedal|
	p[key] = { Impulse.ar(rate.dup, 0, amp) };
	p[key].play;
};

m.pedalNoise = { |self, amp=0.01, key=\pedal|
	p[key] = { WhiteNoise.ar(amp.dup) };
	p[key].play;
};

m.pedalStop = { |self, key=\pedal| p[key].stop };

// -----------------------------------------------------------
"MatrixHarmonyLib loaded.".postln;
"  m.boot     to start".postln;
"  m.send     to set parameters".postln;
"  m.finish   to end".postln;
)
