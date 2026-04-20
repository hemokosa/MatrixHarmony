// ============================================================
// Matrix Harmony - 06: 応用テクニック
// ============================================================
// 最初に MatrixHarmonyLib.scd を評価しておくこと。
//
// 保持音、輪郭と骨組、二重和声進行。
// ============================================================

m.boot;
p.fadeTime = 0;


// ===== 保持音 =====

~out = m.interp;
~out.play;

// 高域の保持音(8820Hz)
m.pedal(8820, 0.1);

// 保持音の上で音響ドミナント・モーションを展開
(
var dur = 3, dt = 10;
var base = 441;
var farray2 = Array.fill(64, 1.0);
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
			\level, 0.4, \dur, dur, \base1, base, \base2, base,
			\farray1, farray1, \farray2, farray2,
			\aarray1, aarray1.normalizeSum, \aarray2, aarray2.normalizeSum,
			\parray1, parray1, \parray2, parray2);
		dt.wait;
	}
};
x.play;
)

// 保持音を変化させる
m.pedal(88.2, 0.5);             // 低域に移動
m.pedal(441, 0.1);              // 和声の基音
m.pedalPulse(70, 10, 0.3);      // 断続する線
m.pedalImpulse(2, 0.5);         // 点列
m.pedalNoise(0.01);             // 面(ノイズ)

x.stop;
m.pedalStop;


// ===== 輪郭と骨組 =====

p.fadeTime = 10;
~out = m.interp;
~out.play;

// 和音の最高音と最低音を保持(輪郭を規定する)
(
var dur = 10, dt = 10;
var base = 441;
var flow = 1.0, fhigh = 4.0;
var ratios = [15/16, 1, 16/15];
var farray2 = [flow, fhigh] ++ Array.rand(62, flow, fhigh);
var aarray2 = [1.0, 1.0] ++ Array.rand(62, 0.0, 1.0);
var parray2 = Array.fill(64, { 1.0.rand2 });
x = TaskProxy.new;
x.source = {
	loop {
		var farray1, aarray1, parray1;
		flow = flow * ratios.choose;
		fhigh = fhigh * ratios.choose;
		farray1 = farray2;
		aarray1 = aarray2;
		parray1 = parray2;
		farray2 = [flow, fhigh] ++ Array.rand(62, flow, fhigh);
		aarray2 = [1.0, 1.0] ++ Array.rand(62, 0.0, 1.0);
		parray2 = Array.fill(64, { 1.0.rand2 });
		m.send(~out,
			\level, 0.4, \dur, dur, \base1, base, \base2, base,
			\farray1, farray1, \farray2, farray2,
			\aarray1, aarray1.normalizeSum, \aarray2, aarray2.normalizeSum,
			\parray1, parray1, \parray2, parray2);
		dt.wait;
	}
};
x.play;
)
x.stop;

// 3和音(長3和音)を骨組として保持
(
var dur = 10, dt = 10;
var base = 441;
var ftriad = m.majorTriad;
var fadd = Array.fill(61, { ftriad.choose });
var ratios = [15/16, 1, 16/15];
var farray2 = ftriad ++ fadd;
var aarray2 = [1.0, 1.0, 1.0] ++ Array.rand(61, 0.0, 1.0);
var parray2 = Array.fill(64, { 1.0.rand2 });
x = TaskProxy.new;
x.source = {
	loop {
		var farray1, aarray1, parray1;
		fadd = fadd * Array.fill(61, { ratios.choose });
		farray1 = farray2;
		aarray1 = aarray2;
		parray1 = parray2;
		farray2 = ftriad ++ fadd;
		aarray2 = [1.0, 1.0, 1.0] ++ Array.rand(61, 0.0, 1.0);
		parray2 = Array.fill(64, { 1.0.rand2 });
		m.send(~out,
			\level, 0.4, \dur, dur, \base1, base, \base2, base,
			\farray1, farray1, \farray2, farray2,
			\aarray1, aarray1.normalizeSum, \aarray2, aarray2.normalizeSum,
			\parray1, parray1, \parray2, parray2);
		dt.wait;
	}
};
x.play;
)
x.stop;


// ===== 二重和声進行(持続と変化) =====

p.fadeTime = 3;
~out = m.dualInterp;
~out.play;

// 上行する和声 + 下行する和声
(
var dur = 3, dt = 3;
var base1 = 441, base2 = 441;
var ratioUp = [1, 16/15];
var ratioDown = [15/16, 1];
var fa12 = Array.exprand(32, 1.0, 4.0);
var aa12 = Array.rand(32, 0.0, 1.0);
var pa12 = Array.fill(32, { 1.0.rand2 });
var fa22 = Array.exprand(32, 1.0, 4.0);
var aa22 = Array.rand(32, 0.0, 1.0);
var pa22 = Array.fill(32, { 1.0.rand2 });
x = TaskProxy.new;
x.source = {
	loop {
		var fa11 = fa12, aa11 = aa12, pa11 = pa12;
		var fa21 = fa22, aa21 = aa22, pa21 = pa22;
		fa12 = fa11 * Array.fill(32, { ratioDown.choose });
		aa12 = Array.rand(32, 0.0, 1.0);
		pa12 = Array.fill(32, { 1.0.rand2 });
		fa22 = fa21 * Array.fill(32, { ratioUp.choose });
		aa22 = Array.rand(32, 0.0, 1.0);
		pa22 = Array.fill(32, { 1.0.rand2 });
		m.send(~out,
			\dur, dur,
			\base11, base1, \base12, base1,
			\base21, base2, \base22, base2,
			\farray11, fa11, \farray12, fa12,
			\aarray11, aa11.normalizeSum, \aarray12, aa12.normalizeSum,
			\parray11, pa11, \parray12, pa12,
			\farray21, fa21, \farray22, fa22,
			\aarray21, aa21.normalizeSum, \aarray22, aa22.normalizeSum,
			\parray21, pa21, \parray22, pa22);
		dt.wait;
	}
};
x.play;
)
x.stop;

// しだいに消えていく(疎になっていく)和声
(
var dur = 1, dt = 5;
var base1 = 441, base2 = 441;
var ratioUp = [1, 16/15];
var ratioDown = [15/16, 1];
var fa12 = Array.exprand(32, 1.0, 4.0);
var aa12 = Array.fill(32, 1.0);
var pa12 = Array.fill(32, { 1.0.rand2 });
var fa22 = Array.exprand(32, 1.0, 4.0);
var aa22 = Array.fill(32, 1.0);
var pa22 = Array.fill(32, { 1.0.rand2 });
x = TaskProxy.new;
x.source = {
	loop {
		var fa11 = fa12, aa11 = aa12, pa11 = pa12;
		var fa21 = fa22, aa21 = aa22, pa21 = pa22;
		fa12 = fa11 * Array.fill(32, { ratioDown.choose });
		aa12 = m.fade(aa11, 0.5);
		pa12 = Array.fill(32, { 1.0.rand2 });
		fa22 = fa21 * Array.fill(32, { ratioUp.choose });
		aa22 = m.fade(aa21, 0.5);
		pa22 = Array.fill(32, { 1.0.rand2 });
		m.send(~out,
			\dur, dur,
			\base11, base1, \base12, base1,
			\base21, base2, \base22, base2,
			\farray11, fa11, \farray12, fa12,
			\aarray11, aa11.normalizeSum, \aarray12, aa12.normalizeSum,
			\parray11, pa11, \parray12, pa12,
			\farray21, fa21, \farray22, fa22,
			\aarray21, aa21.normalizeSum, \aarray22, aa22.normalizeSum,
			\parray21, pa21, \parray22, pa22);
		dt.wait;
	}
};
x.play;
)
x.stop;

// --- 終了 ---
~out.stop;
m.finish;
