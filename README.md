# LocusView

### これはなに

`CALayer` の `Animation` の軌跡を `presentationLayer` から `NSTimer` で定期的に取って、そこから `UIBezierPath` で頑張って軌跡を描いてみる感じのやつ。

### 使い方

```swift
// InterfaceBuilder からでも、コードからでも良いんだけど `LocusView` を作る。
// IB から作ると主要な ivar は `@IBInspectable` 付けてるから直接弄れるよ。

// 主に PanGestureRecognizer やらセンサーのデータを正規化して moveToPoint を連続で叩いていく感じの想定だよ。
// メインスレッドから叩いてね。

let point = CGPointMake(x, y)  // 左上原点の (0.0, 0.0) から右下が (1.0, 1.0) に正規化してね
locusView.moveToPoint(point)   // 適当に軌跡を描きながらアニメーションで動く

locusView.currentPoint = point // アニメーションとかせずにパっと移動する

```

### 他に弄れるプロパティとか

- 円の直径
- 円の色
- 尻尾の色
- 尻尾の長さを何秒くらい保持しておくか

全部アニメーション中に弄っても特に壊れないようになってる。



# ToDo

- `CocoaPods` や `carthage`
- `README` 英語で書く。
- あとでやる。



# LICENSE

Copyright (c) 2015 Yusuke Sugamiya

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
