#### Many things..

- Hashes are indexed using the square brackets (`[]`) and accessing either the `string literal` you used for the key, or the `symbol`.

```ruby
# how to define?
hash = { 'key1' => 'value1', 'key2' => 'value2' }
# or this way not recommended in general. hash = { :key1 => "value1", :key2 => "value2"}
hash = { key1: 'value1', key2: 'value2' }
# how to access?
hash['key1']
hash[:key1]
```

- [Ruby で%記法（パーセント記法）を使う](https://qiita.com/mogulla3/items/46bb876391be07921743)
- `form_with` で送信されたフォームは、デフォルトで非同期通信（Ajax）リクエストで送信される。よって `form_tag` と `form_for` のように、`remote: true` と指定する必要がない。リモートフォームを無効にしたい場合は、`local: true` と指定する。 [ref](https://qiita.com/hmmrjn/items/24f3b8eade206ace17e2) Rails の `erb` 内で active record 使えるの善き。フォームへの id 自動付与も善き。
- `ApplicationRecord` クラスは、Active Record が提供する基本クラス `ActiveRecord::Base` を継承している。
- `ApplicationController` クラスは、`ActionController::Base` を継承している。

```text
rails server : rails s
rails console : rails c
rails generate : rails g
rails test : rails t
bundle install : bundle
```

- 誤って rails generate してしまったときは `destroy` を使う。 モデルの生成あとなどもこれで元に戻すことができる。

```text
rails generate controller StaticPages home help
rails destroy  controller StaticPages home help
```

- migration を元に戻したいときは、rollback を使う。

```text
rails db:migrate
rails db:rollback # 一つ前の状態に戻す!
rails db:migrate VERSION=0 # 最初の状態に戻したいとき　初期の状態 = version 0
```

> Rails の Controller に関して：純粋な Ruby 言語であれば、クラス内の空のソッドは何も実行しません。しかし、Rails では動作が異なります。StaticPagesController は Ruby のクラスですが、ApplicationController クラスを継承しているため、StaticPagesController のメソッドは（たとえ何も書かれていなくても）Rails 特有の振る舞いをします。具体的には、/static_pages/home という URL にアクセスすると、Rails は StaticPages コントローラを参照し、home アクションに記述されているコードを実行します。その後、そのアクションに対応するビュー（/static_pages/home.html.erb）を出力します

- テストの 3 つのメリット:
  1. テストが揃っていれば、機能停止に陥るような回帰バグ（Regression Bug: 以前のバグが再発したり機能の追加/変更に副作用が生じたりすること）を防止できる。
  2. テストが揃っていれば、コードを安全にリファクタリング（機能を変更せずにコードを改善すること）ができる。
  3. テストコードは、アプリケーションコードから見ればクライアントとして動作するので、アプリケーションの設計やシステムの他の部分とのインターフェイスを決めるときにも役に立つ。

```text
「テスト駆動」にするか「一括テスト」にするかを決める目安となるガイドラインがあると便利です。著者の経験を元に、次のようにまとめてみました。

・アプリケーションのコードよりも明らかにテストコードの方が短くシンプルになる（=簡単に書ける）のであれば、「先に」書く
・動作の仕様がまだ固まりきっていない場合、アプリケーションのコードを先に書き、期待する動作を「後で」書く
・セキュリティが重要な課題またはセキュリティ周りのエラーが発生した場合、テストを「先に」書く
・バグを見つけたら、そのバグを再現するテストを「先に」書き、回帰バグを防ぐ体制を整えてから修正に取りかかる
・すぐにまた変更しそうなコード（HTML構造の細部など）に対するテストは「後で」書く
・リファクタリングするときは「先に」テストを書く。特に、エラーを起こしそうなコードや止まってしまいそうなコードを集中的にテストする
・上のガイドラインに従う場合、現実には最初にコントローラやモデルのテストを書き、続いて統合テスト（モデル/ビュー/コントローラにまたがる機能テスト）を書く、ということになります。

また、不安定な要素が特に見当たらないアプリケーションや、（主にビューが）頻繁に改定される可能性の高いアプリケーションのコードを書くときには、思い切ってテストを省略してしまうこともあります。
```

- このサンプルアプリは生まれたてなので、今のところリファクタリングの必要な箇所はほぼどこにも見当たりません。しかし`「一匹いれば 30 匹いると思え」`、[コードの腐敗臭](https://ja.wikipedia.org/wiki/%E3%82%B3%E3%83%BC%E3%83%89%E3%81%AE%E8%87%AD%E3%81%84)はどんな小さな隙間からも忍び寄ってきます。こまめなリファクタリングの習慣をできるだけ早いうちに身につけるためにも、少々無理やりに 3.4.3 から始めることにします。
