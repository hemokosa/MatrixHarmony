// ============================================================
// Matrix Harmony - 02: マトリクス和音(面の思考)
// ============================================================
// 最初に MatrixHarmonyLib.scd を評価しておくこと。
//
// 倍音列(等差数列)と音程列(等比数列)の外積(*.x)による
// 周波数マトリクスの生成。音色と和音の統合的デザイン。
// ============================================================

m.boot;

// 64本のSinOscマトリクスシンセ
~out = m.matrix;
~out.play;

// --- 基本: 倍音列 x 音程列 ---

// 8倍音 x 完全5度の8音(基音100Hz)
m.send(~out, \base, 100,
	\farray, m.harm(8) *.x m.intv(8, m.perfect5),
	\aarray, m.ampInv(8, 8),
	\parray, m.panC(64));

// --- 3度構成の和音 ---

// 古典的長7和音
m.send(~out, \base, 441,
	\farray, m.harm(16) *.x m.maj7,
	\aarray, m.ampInv(16, 4),
	\parray, m.panC(64));

// 古典的短7和音
m.send(~out, \base, 441,
	\farray, m.harm(16) *.x m.min7,
	\aarray, m.ampInv(16, 4),
	\parray, m.panC(64));

// ランダムな3度構成の8音和音
(
m.send(~out, \base, 441,
	\farray, m.harm(8) *.x m.chain(8, m.thirds),
	\aarray, m.ampInv(8, 8),
	\parray, m.panR(64));
)

// 2つのランダムな3度音程列の外積
(
m.send(~out, \base, 441,
	\farray, m.chain(8, m.thirds) *.x m.chain(8, m.thirds),
	\aarray, m.ampProdInv(8, 8),
	\parray, m.panC(64));
)

// --- 4度構成の和音 ---

// 完全4度の8音和音
m.send(~out, \base, 441,
	\farray, m.harm(8) *.x m.intv(8, m.perfect4),
	\aarray, m.ampInv(8, 8),
	\parray, m.panC(64));

// 増4度(トライトーン)の8音和音
m.send(~out, \base, 441,
	\farray, m.harm(8) *.x m.intv(8, 2.sqrt),
	\aarray, m.ampInv(8, 8),
	\parray, m.panC(64));

// 長3度 x 完全4度
m.send(~out, \base, 441,
	\farray, m.intv(8, m.major3) *.x m.intv(8, m.perfect4),
	\aarray, m.ampProdInv(8, 8),
	\parray, m.panC(64));

// --- ペンタトニック / ホールトーン ---

// ペンタトニック音程の8音和音
m.send(~out, \base, 441,
	\farray, m.harm(8) *.x m.intv(8, m.et(5)),
	\aarray, m.ampInv(8, 8),
	\parray, m.panC(64));

// ホールトーンの8音和音(ランダム振幅、ランダムパン)
m.send(~out, \base, 441,
	\farray, m.harm(8) *.x m.intv(8, m.et(6)),
	\aarray, m.ampExp(64),
	\parray, m.panR(64));

// --- 下方倍音列を用いた和音 ---

// 倍音列と下方倍音列の組み合わせ(基音から上下に広がる)
m.send(~out, \base, 1750,
	\farray, m.harm(8) *.x m.subharm(8),
	\aarray, m.ampProdInv(8, 8),
	\parray, m.panC(64));

// ぶらさがる和音(下行音程 x 下方倍音列)
(
m.send(~out, \base, 22050,
	\farray, m.subharm(8) *.x m.chainDown(8),
	\aarray, m.ampInv(8, 8),
	\parray, m.panC(64));
)

// --- クラスター ---

// 2度/7度構成のランダムクラスター
(
var pool = [m.minor2, m.major2, m.minor7, m.major7];
m.send(~out, \base, 150,
	\farray, m.chain(8, pool) *.x m.chain(8, pool),
	\aarray, m.ampRand(64),
	\parray, m.panR(64));
)

// --- 部分集合(疎な和音) ---

// ホールトーンマトリクスの30%だけ発音
m.send(~out, \base, 441,
	\farray, m.harm(8) *.x m.intv(8, m.et(6)),
	\aarray, m.ampSparse(64, 0.3),
	\parray, m.panR(64));

// --- ランダムリスニング ---
(
x = TaskProxy.new;
x.source = {
	loop {
		m.send(~out, \base, 20,
			\farray, m.intv(8, m.allIntervals.choose) *.x m.intv(8, m.allIntervals.choose),
			\aarray, m.ampRand(64),
			\parray, m.panR(64));
		10.wait;
	}
};
x.play;
)
x.stop;

// --- 終了 ---
~out.stop;
m.finish;
