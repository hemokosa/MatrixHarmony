// ============================================================
// Matrix Harmony - 05: 自動和声進行
// ============================================================
// 最初に MatrixHarmonyLib.scd を評価しておくこと。
//
// TaskProxy を用いた音響和声の連鎖の自動化。
// ============================================================

m.boot;
p.fadeTime = 0;

~out = m.interp;
~out.play;

// ===== 音響ドミナント・モーションの連鎖 =====
(
var dur = 3, dt = 10;
var base = 441;
var farray2 = Array.exprand(64, 1.0, 8.0);
var aarray2 = Array.rand(64, 0.0, 1.0);
var parray2 = Array.fill(64, { 1.0.rand2 });
x = TaskProxy.new;
x.source = {
	loop {
		var farray1 = farray2;
		var aarray1 = aarray2;
		var parray1 = parray2;
		farray2 = m.dominant(farray1);
		aarray2 = Array.rand(64, 0.0, 1.0);
		parray2 = Array.fill(64, { 1.0.rand2 });
		m.send(~out,
			\dur, dur, \base1, base, \base2, base,
			\farray1, farray1, \farray2, farray2,
			\aarray1, aarray1.normalizeSum, \aarray2, aarray2.normalizeSum,
			\parray1, parray1, \parray2, parray2);
		dt.wait;
	}
};
x.play;
)
x.stop;

// さまざまな初期値で聴きくらべる:
// 疎な和音: Array.exprand(64, 1.0, 100.0)
// 1本の線: Array.fill(64, 1.0)
// 5度構成: m.harm(8) *.x m.intv(8, 3/2)


// ===== 緊張と弛緩(解決)の連鎖 =====
(
var dur = 10, dt = 10;
var base = 50;
var consonantFreqs = m.harm(8) *.x m.intv(8, m.perfect5);
var consonantAmps = m.ampInv(8, 8);
var farray2 = consonantFreqs;
var aarray2 = consonantAmps;
var parray2 = Array.fill(64, { 1.0.rand2 });
x = TaskProxy.new;
x.source = {
	loop {
		var farray1, aarray1, parray1;
		// 緊張: ランダムな周波数変化
		farray1 = farray2;
		aarray1 = aarray2;
		parray1 = parray2;
		farray2 = farray2 * Array.fill(64, { rrand(4/5, 5/4) });
		aarray2 = Array.rand(64, 0.0, 1.0);
		parray2 = Array.fill(64, { 1.0.rand2 });
		m.send(~out,
			\dur, dur, \base1, base, \base2, base,
			\farray1, farray1, \farray2, farray2,
			\aarray1, aarray1.normalizeSum, \aarray2, aarray2.normalizeSum,
			\parray1, parray1, \parray2, parray2);
		dt.wait;
		// 弛緩: 協和音程に戻る
		farray1 = farray2;
		aarray1 = aarray2;
		parray1 = parray2;
		farray2 = consonantFreqs;
		aarray2 = consonantAmps;
		parray2 = Array.fill(64, { 1.0.rand2 });
		m.send(~out,
			\dur, dur, \base1, base, \base2, base,
			\farray1, farray1, \farray2, farray2,
			\aarray1, aarray1.normalizeSum, \aarray2, aarray2.normalizeSum,
			\parray1, parray1, \parray2, parray2);
		dt.wait;
	}
};
x.play;
)
x.stop;

// ===== ペンタトニック部分集合の自動変化 =====
(
x = TaskProxy.new;
x.source = {
	loop {
		m.send(~out,
			\dur, 3, \base1, 441, \base2, 441,
			\farray1, m.harm(8) *.x m.intv(8, m.et(5)),
			\farray2, m.harm(8) *.x m.intv(8, m.et(5)),
			\aarray1, m.ampSparse(64, 0.2),
			\aarray2, m.ampSparse(64, 0.2),
			\parray1, m.panR(64),
			\parray2, m.panR(64));
		10.wait;
	}
};
x.play;
)
x.stop;

// --- 終了 ---
~out.stop;
m.finish;
