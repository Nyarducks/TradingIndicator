# TradingIndicator
Indicator for MQL4 Trading to check your positions

## Installation

1. `Meta Trading 4`を起動する
2. メニューバーにある`File -> Open Data Folder`から`MQL4\Indicators`に`TradingIndicator.ex4`を配置してください。

## How to
1. ナビゲーターバーから`Indicators -> TradingIndicator`を選択してインジケーターを読み込んでください。(設定はありません)

## tips
- インジケーターは仕様上、MT4を再起動すると初期状態になります。そのため再度インジケーターを読み込むようにしてください。
- 最大DDは1日あたりの取引中のポジションの割合を表示します。
- 最大含み損は1日あたりの取引中に生じた含み損のピーク値を表示します。
- 現在のBUY/SELLポジションの価格は損益分岐価格とポジション数を表示します。
