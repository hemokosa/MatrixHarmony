// ============================================================
// Matrix Harmony - 07: 連続補間（マトリクス列の補間）
// ============================================================
// 最初に MatrixHarmonyLib.scd を評価しておくこと。
//
// 3つ以上のマトリクスを順に線形補間して遷移する。
// m.interpSeq を用いた和声進行の自動化。
// ============================================================

m.boot;
p.fadeTime = 0;

~out = m.interp;
~out.play;


// ===== 基本: 3つの和音を順に補間 =====
// 完全5度 → 長3度 → 短2度 → 完全5度（ループ）

(
var base = 200;
var specs = [
	(base: base,
		farray: m.harm(8) *.x m.intv(8, m.perfect5),
		aarray: m.ampInv(8, 8),
		parray: m.panR(64)),
	(base: base,
		farray: m.harm(8) *.x m.intv(8, m.major3),
		aarray: m.ampInv(8, 8),
		parray: m.panR(64)),
	(base: base,
		farray: m.harm(8) *.x m.intv(8, m.minor2),
		aarray: m.ampInv(8, 8),
		parray: m.panR(64)),
	(base: base,
		farray: m.harm(8) *.x m.intv(8, m.perfect5),
		aarray: m.ampInv(8, 8),
		parray: m.panR(64)),
];
x = m.interpSeq(~out, specs, dur: 5, dt: 8);
x.play;
)
x.stop;


// ===== 古典的進行: I → IV → V → I =====

(
var base = 441;
var specs = [
	(base: base,
		farray: m.harm(16) *.x m.majorTriad ++ [2],
		aarray: m.ampInv(16, 4),
		parray: m.panR(64)),
	(base: base,
		farray: m.harm(16) *.x [1, 5/4, 3/2, 2] * (4/3),
		aarray: m.ampInv(16, 4),
		parray: m.panR(64)),
	(base: base,
		farray: m.harm(16) *.x [1, 5/4, 3/2, 2] * (3/2),
		aarray: m.ampInv(16, 4),
		parray: m.panR(64)),
	(base: base,
		farray: m.harm(16) *.x m.majorTriad ++ [2],
		aarray: m.ampInv(16, 4),
		parray: m.panR(64)),
];
x = m.interpSeq(~out, specs, dur: 5, dt: 6);
x.play;
)
x.stop;


// ===== 音色変化: 倍音構造を徐々に変える =====
// 整数倍音 → 非整数倍音 → 下方倍音列

(
var base = 300;
var specs = [
	(base: base,
		farray: m.harm(8) *.x m.intv(8, m.perfect5),
		aarray: m.ampInv(8, 8),
		parray: m.panC(64)),
	(base: base,
		farray: m.harm(8, 1, 1.1) *.x m.intv(8, m.perfect5),
		aarray: m.ampExp(64),
		parray: m.panR(64)),
	(base: base * 20,
		farray: m.subharm(8) *.x m.intv(8, m.perfect5),
		aarray: m.ampInv(8, 8),
		parray: m.panR(64)),
	(base: base,
		farray: m.harm(8) *.x m.intv(8, m.perfect5),
		aarray: m.ampInv(8, 8),
		parray: m.panC(64)),
];
x = m.interpSeq(~out, specs, dur: 8, dt: 10);
x.play;
)
x.stop;


// ===== ランダム進行: ランダムな和音列を生成して補間 =====

(
var base = 441;
var intervals = m.allIntervals;
var specs = Array.fill(6, {
	(base: base,
		farray: m.harm(8) *.x m.intv(8, intervals.choose),
		aarray: m.ampRand(64),
		parray: m.panR(64))
});
x = m.interpSeq(~out, specs, dur: 3, dt: 5);
x.play;
)
x.stop;


// ===== 基音の移動を伴う進行 =====

(
var specs = [
	(base: 100,
		farray: m.harm(8) *.x m.intv(8, m.perfect5),
		aarray: m.ampInv(8, 8),
		parray: m.panR(64)),
	(base: 200,
		farray: m.harm(8) *.x m.intv(8, m.major3),
		aarray: m.ampInv(8, 8),
		parray: m.panR(64)),
	(base: 400,
		farray: m.harm(8) *.x m.intv(8, m.minor2),
		aarray: m.ampSparse(64, 0.4),
		parray: m.panR(64)),
	(base: 50,
		farray: m.harm(8) *.x m.intv(8, m.perfect5),
		aarray: m.ampInv(8, 8),
		parray: m.panC(64)),
];
x = m.interpSeq(~out, specs, dur: 8, dt: 10);
x.play;
)
x.stop;


// --- 終了 ---
~out.stop;
m.finish;
