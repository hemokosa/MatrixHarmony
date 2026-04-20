// ============================================================
// Matrix Harmony - 01: 基本とハーモニクス
// ============================================================
// 最初に MatrixHarmonyLib.scd を評価しておくこと。
// ============================================================

m.boot;

// 16本の線(Klang)シンセを作成して再生
~out = m.line16;
~out.play;
~out.vol = 0.8;

// --- 倍音列とその響き ---

// 基音200Hzの第16倍音まで(振幅一定)
m.send(~out, \base, 200,
	\farray, m.harm(16),
	\aarray, m.ampFlat(16));

// ノコギリ波の合成(振幅反比例: 1/n)
m.send(~out, \base, 200,
	\farray, m.harm(16),
	\aarray, m.harm(16).reciprocal.normalizeSum);

// 矩形波の合成(奇数次倍音、振幅1/n)
m.send(~out, \base, 200,
	\farray, m.harm(16, 1, 2),
	\aarray, m.harm(16, 1, 2).reciprocal.normalizeSum);

// 三角波の合成(奇数次倍音、振幅1/n^2)
m.send(~out, \base, 200,
	\farray, m.harm(16, 1, 2),
	\aarray, m.harm(16, 1, 2).squared.reciprocal.normalizeSum);

// --- 倍音列の操作 ---

// 部分倍音列(第10倍音から開始)
m.send(~out, \base, 200,
	\farray, m.harm(16, 10),
	\aarray, m.harm(16).reciprocal.normalizeSum);

// うなりによるクラスター(公差を小さくする)
m.send(~out, \base, 200,
	\farray, m.harm(16, 1, rrand(0.01, 0.1)),
	\aarray, m.ampFlat(16));

// 非整数倍音(金属的な音色)
m.send(~out, \base, 200,
	\farray, m.harm(16, rrand(0.5, 2.0)),
	\aarray, m.harm(16).reciprocal.normalizeSum);

// 公差をランダムにする
m.send(~out, \base, 200,
	\farray, m.harm(16, 1, rrand(0.5, 2.0)),
	\aarray, m.harm(16).reciprocal.normalizeSum);

// --- 下方倍音列 ---

// 基音4410Hzの下方倍音列(振幅一定)
m.send(~out, \base, 4410,
	\farray, m.subharm(16),
	\aarray, m.ampFlat(16));

// 下方倍音列(振幅反比例)
m.send(~out, \base, 4410,
	\farray, m.subharm(16),
	\aarray, m.harm(16).reciprocal.normalizeSum);

// --- 音程列(等比数列) ---

// 長3度の積み重ね
m.send(~out, \base, 200,
	\farray, m.intv(16, m.major3),
	\aarray, m.ampFlat(16));

// 完全5度の積み重ね
m.send(~out, \base, 100,
	\farray, m.intv(16, m.perfect5),
	\aarray, m.ampFlat(16));

// 短2度の積み重ね(密集クラスター)
m.send(~out, \base, 200,
	\farray, m.intv(16, m.minor2),
	\aarray, m.ampFlat(16));

// --- 終了 ---
~out.stop;
m.finish;
