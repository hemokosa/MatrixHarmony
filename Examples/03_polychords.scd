// ============================================================
// Matrix Harmony - 03: ポリコード
// ============================================================
// 最初に MatrixHarmonyLib.scd を評価しておくこと。
//
// 複数のマトリクスの結合(同時的な組み合わせ)による音響和音。
// 異なる基音、異なる音程構造を持つ2つの和音を重ね合わせる。
// ============================================================

m.boot;

// 2 x 32本(デュアル)シンセ
~out = m.dual;
~out.play;

// --- 低域5度和音 + 高域3度和音 ---
m.send(~out,
	\base1, 100,
	\farray1, m.harm(8) *.x m.intv(4, m.perfect5),
	\aarray1, m.ampInv(8, 4),
	\parray1, m.panC(32),
	\base2, 1100,
	\farray2, m.harm(8) *.x m.maj7,
	\aarray2, m.ampInv(8, 4),
	\parray2, m.panC(32));

// --- 短2度関係の2つの和音(複調) ---
m.send(~out,
	\base1, 441,
	\farray1, m.harm(8) *.x m.maj7,
	\aarray1, m.ampInv(8, 4),
	\parray1, m.panR(32),
	\base2, 441 * m.minor2,
	\farray2, m.harm(8) *.x m.min7,
	\aarray2, m.ampInv(8, 4),
	\parray2, m.panR(32));

// --- ランダムな3度構成のポリコード ---
(
m.send(~out,
	\base1, 441,
	\farray1, m.harm(8) *.x m.chain(4, m.thirds),
	\aarray1, m.ampInv(8, 4),
	\parray1, m.panR(32),
	\base2, 441 * m.thirds.choose,
	\farray2, m.harm(8) *.x m.chain(4, m.thirds),
	\aarray2, m.ampInv(8, 4),
	\parray2, m.panR(32));
)

// --- ポリ倍音(異なる倍音列の重ね合わせ) ---
m.send(~out,
	\base1, 441,
	\farray1, m.harm(32),
	\aarray1, m.harm(32).reciprocal.normalizeSum,
	\parray1, m.panC(32),
	\base2, 400,
	\farray2, m.harm(32, 1, 1.1),
	\aarray2, m.harm(32).reciprocal.normalizeSum,
	\parray2, m.panC(32));

// --- 終了 ---
~out.stop;
m.finish;
