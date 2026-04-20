// ============================================================
// Matrix Harmony - 04: 音響和声(立体の思考)
// ============================================================
// 最初に MatrixHarmonyLib.scd を評価しておくこと。
//
// 音響和音の時間的連鎖 = 音響和声。
// 線形補間による和音間の滑らかな遷移。
// ============================================================

m.boot;
p.fadeTime = 0; // 補間シンセはfadeTime不要

// 補間シンセ
~out = m.interp;
~out.play;

// --- 基本的な和音遷移 ---

// 完全5度+短2度 → 長3度+短3度(基音200Hz)
m.send(~out,
	\dur, 10,
	\base1, 200, \base2, 200,
	\farray1, m.intv(8, 1.5) *.x m.intv(8, 1.067),
	\farray2, m.intv(8, 1.25) *.x m.intv(8, 1.2),
	\aarray1, m.ampProdInv(8, 8),
	\aarray2, m.ampProdInv(8, 8),
	\parray1, m.panR(64),
	\parray2, m.panR(64));

// 増4度 → 完全5度(基音50Hz)
m.send(~out,
	\dur, exprand(0.1, 10.0),
	\base1, 50, \base2, 50,
	\farray1, m.harm(8) *.x m.intv(8, 2.sqrt),
	\farray2, m.harm(8) *.x m.intv(8, 1.5),
	\aarray1, m.ampRand(64),
	\aarray2, m.ampInv(8, 8),
	\parray1, m.panR(64),
	\parray2, m.panR(64));

// 長3度 → 自然7度(基音の移動: 100Hz → 50Hz)
m.send(~out,
	\dur, 10,
	\base1, 100, \base2, 50,
	\farray1, m.harm(8) *.x m.intv(8, m.major3),
	\farray2, m.harm(8) *.x m.intv(8, m.natural7),
	\aarray1, m.ampRand(64),
	\aarray2, m.ampRand(64),
	\parray1, m.panR(64),
	\parray2, m.panR(64));

// --- 古典的ドミナント・モーション ---

// V7 → I(主音441Hz)
m.send(~out,
	\dur, 10,
	\base1, 441, \base2, 441,
	\farray1, m.harm(16) *.x [15/16, 9/8, 4/3, 3/2],
	\farray2, m.harm(16) *.x [15/16, 1, 5/4, 3/2],
	\aarray1, m.ampInv(16, 4),
	\aarray2, m.ampInv(16, 4),
	\parray1, m.panR(64),
	\parray2, m.panR(64));

// IIb7 → I(裏コード)
m.send(~out,
	\dur, 10,
	\base1, 441, \base2, 441,
	\farray1, m.harm(16) *.x [15/16, 16/15, 4/3, 8/5],
	\farray2, m.harm(16) *.x [15/16, 1, 5/4, 3/2],
	\aarray1, m.ampInv(16, 4),
	\aarray2, m.ampInv(16, 4),
	\parray1, m.panR(64),
	\parray2, m.panR(64));

// --- 音響ドミナント・モーション ---

// 5度構成の和音に対するランダムな半音進行
(
var tonic = m.harm(8) *.x m.intv(8, m.perfect5);
var dominant = m.dominant(tonic);
m.send(~out,
	\dur, 10,
	\base1, 126, \base2, 126,
	\farray1, dominant,
	\farray2, tonic,
	\aarray1, m.ampInv(8, 8),
	\aarray2, m.ampInv(8, 8),
	\parray1, m.panR(64),
	\parray2, m.panR(64));
)

// 密集した和音のドミナント・モーション
(
var tonic = Array.exprand(64, 1.0, 8.0);
var dominant = m.dominant(tonic);
m.send(~out,
	\dur, 3,
	\base1, 441, \base2, 441,
	\farray1, dominant,
	\farray2, tonic,
	\aarray1, m.ampRand(64),
	\aarray2, m.ampRand(64),
	\parray1, m.panR(64),
	\parray2, m.panR(64));
)

// --- 終了 ---
~out.stop;
m.finish;
