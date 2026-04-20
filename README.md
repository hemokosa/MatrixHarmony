# MatrixHarmony - 音響和声ライブコーディングライブラリ

SuperCollider 用の音響和声（Matrix Harmony）ライブコーディングライブラリ。
正弦波バンクによる周波数マトリクスを通じて、**音色と和声を統一的に扱う**システム。

---

## 概要

従来の音楽理論では音色（timbre）と和声（harmony）は別々に扱われるが、
本ライブラリはどちらも**周波数の集合**として統一的に捉える。

- **倍音列**（等差数列）= 音色を決定する
- **音程列**（等比数列）= 和声を決定する
- **外積** `*.x` = 音色 × 和声 → **周波数マトリクス**

64本の正弦波オシレータの周波数・振幅・パンを直接制御することで、
音色と和音の境界を超えた音響デザインとライブコーディングが可能になる。

---

## セットアップ

### 必要環境

- SuperCollider 3.x

### インストール

特別なインストール不要。`MatrixHarmonyLib.scd` を評価するだけで使える。

```
// 1. MatrixHarmonyLib.scd を SuperCollider で開く
// 2. ファイル全体を評価 (Cmd+Shift+Enter / Ctrl+Shift+Enter)
// → "MatrixHarmonyLib loaded." と表示されれば成功
```

---

## クイックスタート

```supercollider
// ライブラリを評価後:

m.boot;                  // サーバー起動 + ProxySpace push
~out = m.matrix;         // 64本SinOscマトリクスシンセを定義
~out.play;               // 再生開始

// 8倍音 x 完全5度8音の和音
m.send(~out, \base, 200,
    \farray, m.harm(8) *.x m.intv(8, m.perfect5),
    \aarray, m.ampInv(8, 8),
    \parray, m.panR(64));

// 長3度8音に変更
m.send(~out, \base, 200,
    \farray, m.harm(8) *.x m.intv(8, m.major3),
    \aarray, m.ampInv(8, 8),
    \parray, m.panC(64));

~out.stop;
m.finish;                // 終了・クリーンアップ
```

---

## アーキテクチャ

```
解釈変数 m (Event, know: true)
├── 音程定数      m.perfect5, m.major3, m.minor2, ...
├── 和音テンプレート  m.majorTriad, m.min7, m.dom7, ...
├── 周波数配列生成  m.harm, m.subharm, m.intv, m.chain, ...
├── 振幅配列生成    m.ampInv, m.ampRand, m.ampSparse, ...
├── パン配列生成    m.panC, m.panR
├── 変換          m.dominant, m.detune, m.thin, m.fade
├── シンセ関数     m.line16, m.matrix, m.interp, m.dual, m.dualInterp
├── セットアップ    m.boot, m.send, m.finish
├── 連続補間       m.interpSeq
└── 保持音        m.pedal, m.pedalPulse, m.pedalImpulse, m.pedalNoise, m.pedalStop

解釈変数 p = ProxySpace (m.boot で push される)
```

### 設計原則

- ライブラリは**解釈変数 `m`** に格納（ProxySpace push 後も `m.xxx` でアクセス可能）
- シンセ関数は **Function を返す**（NodeProxy ではない）ので `~out = m.matrix` が ProxySpace で正しく動作
- `m.send(proxy, ...)` は `proxy.setn(...).rebuild` のショートカット（setn で値を保存し rebuild でシンセ再構築）

---

## API リファレンス

### セットアップ & トランスポート

| メソッド | 説明 |
|---------|------|
| `m.boot(fadeTime)` | サーバー起動、ProxySpace を `p` に push。`fadeTime` デフォルト 1.0 秒 |
| `m.send(proxy, ...)` | NodeProxy にパラメータを設定して rebuild。`m.send(~out, \base, 200, \farray, [...], ...)` |
| `m.finish(fadeOut)` | ProxySpace を end → clear → pop → free。`fadeOut` デフォルト 10 秒 |

### 音程定数（純正律）

| 定数 | 比率 | 音程 |
|------|------|------|
| `m.unison` | 1 | 完全1度 |
| `m.minor2` | 16/15 | 短2度 |
| `m.smallWhole` | 10/9 | 小全音 |
| `m.major2` | 9/8 | 長2度 |
| `m.minor3` | 6/5 | 短3度 |
| `m.major3` | 5/4 | 長3度 |
| `m.perfect4` | 4/3 | 完全4度 |
| `m.aug4` | 45/32 | 増4度 |
| `m.dim5` | 64/45 | 減5度 |
| `m.perfect5` | 3/2 | 完全5度 |
| `m.minor6` | 8/5 | 短6度 |
| `m.major6` | 5/3 | 長6度 |
| `m.natural7` | 7/4 | 自然7度 |
| `m.minor7` | 16/9 | 短7度 |
| `m.major7` | 15/8 | 長7度 |
| `m.octave` | 2 | オクターブ |

### 音程グループ

| 定数 | 内容 |
|------|------|
| `m.allIntervals` | 全14音程 |
| `m.consonant` | 協和音程: 短3度, 長3度, 完全5度, 短6度, 長6度 |
| `m.dissonant` | 不協和音程: 短2度, 長2度, 短7度, 長7度 |
| `m.seconds` | 2度群 |
| `m.thirds` | 3度群 (短3度, 長3度) |
| `m.fourths` | 4度群 |
| `m.fifths` | 5度群 |
| `m.sixths` | 6度群 |
| `m.sevenths` | 7度群 |

### 和音テンプレート

| 定数 | 構成 |
|------|------|
| `m.majorTriad` | [1, 5/4, 3/2] |
| `m.minorTriad` | [1, 6/5, 3/2] |
| `m.dom7` | [1, 5/4, 3/2, 16/9] |
| `m.maj7` | [1, 5/4, 3/2, 15/8] |
| `m.min7` | [1, 6/5, 3/2, 16/9] |

### n平均律

| メソッド | 説明 |
|---------|------|
| `m.et(n)` | n平均律の1ステップの比率を返す。`m.et(12)` → 12平均律の半音 |

### 周波数配列生成

| メソッド | 説明 | 例 |
|---------|------|-----|
| `m.harm(n, start, step)` | 倍音列（等差数列）。デフォルト: n=8, start=1, step=1 | `m.harm(8)` → [1,2,3,4,5,6,7,8] |
| `m.subharm(n)` | 下方倍音列（1/1, 1/2, 1/3, ...） | `m.subharm(8)` → [1, 0.5, 0.333...] |
| `m.intv(n, ratio, start)` | 音程列（等比数列） | `m.intv(8, 3/2)` → 5度の積み重ね |
| `m.chain(n, pool)` | ランダム音程連鎖（累積積） | `m.chain(8, m.thirds)` → ランダムな3度構成 |
| `m.chainDown(n, pool)` | 下行ランダム音程連鎖 | `m.chainDown(8)` → 下行音程の連鎖 |

**外積によるマトリクス生成:**

```supercollider
// 8倍音 x 完全5度8音 = 64個の周波数
m.harm(8) *.x m.intv(8, m.perfect5)

// ランダム3度構成 x ランダム3度構成 = 64個の周波数
m.chain(8, m.thirds) *.x m.chain(8, m.thirds)
```

### 振幅配列生成

| メソッド | 説明 |
|---------|------|
| `m.ampFlat(n)` | 一定振幅（全要素均等、normalizeSum 済み） |
| `m.ampInv(nH, nI)` | 倍音次数に反比例（自然な減衰カーブ） |
| `m.ampInvRev(nH, nI)` | 反比例の逆順（高次倍音強調） |
| `m.ampProg(nH, nI)` | 高域強調（倍音次数に比例） |
| `m.ampProdInv(nH, nI)` | 積の逆数（距離に反比例） |
| `m.ampRand(n)` | ランダム振幅（一様分布） |
| `m.ampExp(n)` | ランダム振幅（指数分布、ダイナミクス大） |
| `m.ampSparse(n, density)` | 疎な振幅（density の確率で発音） |

### パン配列生成

| メソッド | 説明 |
|---------|------|
| `m.panC(n)` | 全要素センター (0.0) |
| `m.panR(n)` | ランダムなステレオ配置 (-1.0 〜 1.0) |

### 変換

| メソッド | 説明 |
|---------|------|
| `m.dominant(freqs, ratios)` | 各周波数を半音上下にランダムシフト（音響ドミナント） |
| `m.detune(freqs, amount)` | 周波数にランダムなずれを加算（デチューン） |
| `m.thin(amps, keepRatio)` | 振幅をランダムに間引く |
| `m.fade(amps, factor)` | 振幅をランダムに減衰 |

### シンセ関数

全シンセ関数は **Function を返す**。`~out = m.matrix` のように ProxySpace で使用する。

| シンセ | 本数 | 補間 | 主な用途 |
|--------|------|------|---------|
| `m.line16` | 16 (Klang) | なし | 音色探索、軽量な実験 |
| `m.matrix` | 64 (SinOsc) | なし | マトリクス和音の基本 |
| `m.interp` | 64 (SinOsc) | Line.kr | 和音間の滑らかな遷移 |
| `m.dual` | 2 x 32 (SinOsc) | なし | ポリコード（複和音） |
| `m.dualInterp` | 2 x 32 (SinOsc) | Line.kr | 二重和声進行 |

#### シンセのコントロールパラメータ

**m.line16:**
- `base` (441): 基音周波数 — farray の各要素にかけられる
- `fscale` (1): Klang の周波数スケーリング
- `foffset` (0): Klang の周波数オフセット
- `pan` (0): パン位置 (-1.0 〜 1.0)
- `level` (0.8): 出力レベル
- `\farray` [16]: 周波数比の配列
- `\aarray` [16]: 振幅の配列

**m.matrix:**
- `base` (441): 基音周波数
- `level` (0.8): 出力レベル
- `\farray` [64]: 周波数比の配列
- `\aarray` [64]: 振幅の配列
- `\parray` [64]: パン位置の配列

**m.interp:**
- `dur` (10): 補間時間（秒）
- `base1` (441), `base2` (441): 始点/終点の基音周波数
- `level` (0.8): 出力レベル
- `\farray1` [64], `\farray2` [64]: 始点/終点の周波数比
- `\aarray1` [64], `\aarray2` [64]: 始点/終点の振幅
- `\parray1` [64], `\parray2` [64]: 始点/終点のパン

**m.dual:**
- `base1` (441), `base2` (441): 2つの和音それぞれの基音
- `level` (0.4): 出力レベル
- `\farray1` [32], `\farray2` [32]: 各和音の周波数比
- `\aarray1` [32], `\aarray2` [32]: 各和音の振幅
- `\parray1` [32], `\parray2` [32]: 各和音のパン

**m.dualInterp:**
- `dur` (10): 補間時間
- `base11`, `base12`, `base21`, `base22`: 2和音 x 始点/終点の基音
- `level` (0.4): 出力レベル
- `\farray11` [32] ... `\parray22` [32]: 2和音 x 始点/終点の全パラメータ

### 連続補間

| メソッド | 説明 |
|---------|------|
| `m.interpSeq(proxy, specs, dur, dt, repeat, level)` | 3つ以上のマトリクスを順に線形補間する TaskProxy を返す |

**引数:**

| 引数 | デフォルト | 説明 |
|------|-----------|------|
| `proxy` | — | `m.interp` を割り当てた NodeProxy (例: `~out`) |
| `specs` | — | マトリクス仕様の配列。各要素は Event `(base: 441, farray: [...], aarray: [...], parray: [...])` |
| `dur` | 5 | 各遷移の補間時間（秒） |
| `dt` | 5 | 各遷移間の待機時間（秒、dur 以上を推奨） |
| `repeat` | true | true で無限ループ |
| `level` | 0.4 | 出力レベル |

**使用例:**

```supercollider
~out = m.interp;
~out.play;

(
var specs = [
    (base: 200, farray: m.harm(8) *.x m.intv(8, m.perfect5),
                aarray: m.ampInv(8, 8), parray: m.panR(64)),
    (base: 200, farray: m.harm(8) *.x m.intv(8, m.major3),
                aarray: m.ampInv(8, 8), parray: m.panR(64)),
    (base: 200, farray: m.harm(8) *.x m.intv(8, m.minor2),
                aarray: m.ampInv(8, 8), parray: m.panR(64)),
];
x = m.interpSeq(~out, specs, dur: 5, dt: 8);
x.play;   // A → B → C → A → B → C → ... ループ開始
)
x.stop;   // 停止
```

### 保持音

| メソッド | 説明 |
|---------|------|
| `m.pedal(freq, amp, key)` | 持続正弦波 |
| `m.pedalPulse(freq, rate, amp, key)` | 断続する正弦波（LFPulse 変調） |
| `m.pedalImpulse(rate, amp, key)` | インパルス列 |
| `m.pedalNoise(amp, key)` | ホワイトノイズ |
| `m.pedalStop(key)` | 保持音の停止 |

---

## Examples 解説

### 01_basics_and_harmonics.scd — 基本とハーモニクス

**概要:** `m.line16`（16本 Klang）を使った倍音列の探索。

**内容:**
- 倍音列による古典的波形合成（ノコギリ波、矩形波、三角波）
- 部分倍音列（高次倍音からの開始）
- うなり（公差を小さくした倍音列）
- 非整数倍音（金属的な音色）
- 下方倍音列
- 音程列（等比数列）による和音構成

**学べること:** 等差数列（倍音列）と等比数列（音程列）の違い、base パラメータの意味

---

### 02_matrix_chords.scd — マトリクス和音（面の思考）

**概要:** `m.matrix`（64本 SinOsc）と外積 `*.x` によるマトリクス和音の生成。

**内容:**
- 倍音列 x 音程列 の外積による基本マトリクス和音
- 3度構成の和音（長7、短7、ランダム3度和音）
- 4度構成の和音（完全4度、増4度）
- ペンタトニック / ホールトーン
- 下方倍音列を用いた和音
- クラスター（2度/7度構成）
- 部分集合（`m.ampSparse` による疎な和音）
- TaskProxy によるランダム自動リスニング

**学べること:** 外積 `*.x` による「面の思考」、振幅分布による音色制御、`m.ampSparse` による部分集合化

---

### 03_polychords.scd — ポリコード

**概要:** `m.dual`（2 x 32本）による複和音。異なる基音・音程構造を持つ2つの和音の同時発音。

**内容:**
- 低域5度和音 + 高域3度和音
- 短2度関係の複調（2つの調性の重ね合わせ）
- ランダム3度構成のポリコード
- ポリ倍音（異なる倍音構造の重ね合わせ）

**学べること:** 複和音による立体的な音響空間の構築、base1/base2 による独立した基音制御

---

### 04_harmony_progression.scd — 音響和声（立体の思考）

**概要:** `m.interp`（64本 + Line.kr）による和音間の滑らかな遷移。

**内容:**
- 基本的な和音遷移（完全5度+短2度 → 長3度+短3度）
- 増4度 → 完全5度 の解決
- 基音の移動を伴う遷移
- 古典的ドミナント・モーション（V7 → I、裏コード IIb7 → I）
- 音響ドミナント・モーション（`m.dominant` による半音シフト）

**学べること:** `m.send` + `rebuild` パターン、`dur` による遷移速度の制御、古典的和声と音響和声の対比

---

### 05_auto_progressions.scd — 自動和声進行

**概要:** `TaskProxy` を使った音響和声進行の自動化。

**内容:**
- 音響ドミナント・モーションの連鎖（半音ランダムシフトの反復）
- 緊張と弛緩の連鎖（ランダム変化 → 協和音程への解決の繰り返し）
- ペンタトニック部分集合の自動変化

**学べること:** TaskProxy によるリアルタイム和声自動化、ループパターンの設計

---

### 06_advanced_techniques.scd — 応用テクニック

**概要:** 保持音、輪郭と骨組、二重和声進行の応用。

**内容:**
- **保持音:** `m.pedal`, `m.pedalPulse`, `m.pedalImpulse`, `m.pedalNoise` を和声進行の背景として使用
- **輪郭と骨組:** 和音の最高音・最低音を固定し内部だけ変化させる / 3和音を骨組として保持しつつ付加音を変化させる
- **二重和声進行:** `m.dualInterp` による上行和声 + 下行和声の対位法的進行、徐々に消えていく和声

**学べること:** 音楽的構造の高度な制御、対位法的発想の音響和声への応用

---

### 07_sequential_interpolation.scd — 連続補間（マトリクス列の補間）

**概要:** `m.interpSeq` による3つ以上のマトリクスの順次補間。

**内容:**
- 基本: 3つの和音を順にループ（完全5度 → 長3度 → 短2度 → 完全5度）
- 古典的進行: I → IV → V → I
- 音色変化: 整数倍音 → 非整数倍音 → 下方倍音列
- ランダム進行: ランダムな和音列を生成して補間
- 基音の移動を伴う進行

**学べること:** `m.interpSeq` による和声進行の宣言的記述、specs 配列の設計パターン

---

## 核心概念: 面の思考と立体の思考

### 面（2次元）: マトリクス和音

```
     音程列（等比数列）→ 和声軸
     i1    i2    i3    i4
h1 [ h1*i1 h1*i2 h1*i3 h1*i4 ]
h2 [ h2*i1 h2*i2 h2*i3 h2*i4 ]  ← 倍音列（等差数列）= 音色軸
h3 [ h3*i1 h3*i2 h3*i3 h3*i4 ]
h4 [ h4*i1 h4*i2 h4*i3 h4*i4 ]
```

`m.harm(4) *.x m.intv(4, ratio)` がこのマトリクスを生成する。
行方向（倍音列）が各音の音色を、列方向（音程列）が和声構造を決定する。

### 立体（3次元）: 音響和声

時間軸を加え、マトリクス A からマトリクス B へ `Line.kr` で連続的に補間する。
`m.interp` シンセの `dur` 秒間で、64本すべての正弦波が同時に目標周波数へ滑らかに移動する。

`m.interpSeq` を使えば、A → B → C → D → ... と複数のマトリクスを順に遷移できる。

### 音響ドミナント

古典和声のドミナント・モーション（V → I 解決）の音響版。
`m.dominant(freqs)` は各周波数を半音上 (16/15) または半音下 (15/16) にランダムシフトする。
この「ずれた」状態から元の和音に補間すると、緊張→解決の効果が生まれる。

---

## ファイル構成

```
MatrixHarmony/
├── MatrixHarmonyLib.scd          ← メインライブラリ（これを評価して使う）
├── MatrixHarmony.scd             ← 元のモノリシックファイル（参照用）
├── README.md                     ← この文書
├── Examples/
│   ├── 01_basics_and_harmonics.scd
│   ├── 02_matrix_chords.scd
│   ├── 03_polychords.scd
│   ├── 04_harmony_progression.scd
│   ├── 05_auto_progressions.scd
│   ├── 06_advanced_techniques.scd
│   └── 07_sequential_interpolation.scd
└── Classes/                      ← クラスベース版（オプション）
    ├── MH.sc
    ├── MHInterval.sc
    └── MHMatrix.sc
```

---

## Tips

- **音が出ない場合:** `m.boot` を先に評価しているか確認。ProxySpace が push されている必要がある
- **パラメータ変更が反映されない場合:** `m.send` は内部で `.rebuild` を呼ぶ。特に `m.interp` シンセでは `Line.kr` を最初から再開するために rebuild が必須
- **CPU負荷が高い場合:** `m.ampSparse` で発音する正弦波を間引くか、`m.line16` で本数を減らす
- **ランダム系を再評価:** `m.chain`, `m.ampRand`, `m.panR` などは評価のたびに異なる結果を返す。気に入った結果は変数に保存しておくとよい
- **dt >= dur を推奨:** `m.interpSeq` で `dt` < `dur` にすると、補間完了前に次の遷移が始まりグリッチが生じる（意図的に使うこともできる）
