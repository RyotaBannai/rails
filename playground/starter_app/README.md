### TOC

<!-- TOC -->

- [TOC](#toc)
- [Many things..](#many-things)
- [Controller/ View](#controller-view)
- [Model](#model)
    - [validation](#validation)
        - [条件付きバリデーション](#条件付きバリデーション)
        - [error message](#error-message)
    - [callback](#callback)
        - [コールバックをスキップ](#コールバックをスキップ)
    - [Association](#association)
    - [ヒントと注意事項](#ヒントと注意事項)
        - [関連付けの詳細情報](#関連付けの詳細情報)
    - [クエリーインターフェース](#クエリーインターフェース)
        - [レコードを更新できないようロックする](#レコードを更新できないようロックする)
        - [結合](#結合)
        - [スコープ](#スコープ)
        - [Other things](#other-things)

<!-- /TOC -->

### Many things..

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

- 誤って rails generate してしまったときは `destroy` を使う。 モデルの生成後などもこれで元に戻すことができる。

```text
rails generate controller StaticPages home help
rails destroy  controller StaticPages home help
```

- migration を元に戻したいときは、rollback を使う。rollback は change メソッドを逆転実行するか down メソッドを実行する。

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

- レコードの保存時に#save メソッドのオプションに`touch: false`を渡すことで、タイムスタンプを更新しないようにできる。`article.save!(touch: false)` `after_touch` コールバックは、Active Record オブジェクトが touch されるたびに呼び出される。belongs_to と併用できる。
- `ActiveRecord::Relation#in_batches`: データ件数が大きなモデルに対して処理を行う`ActiveRecord#find_in_batches`がブロックに配列を渡してレコードを渡すのに対して、`ActiveRecord#in_batches`メソッドは、ブロックに`ActiveRecord::Relation`を渡せる。オプションに`of`を渡すことで、バッチのサイズを変更することができる。
- `ActiveRecord::Attributes`: モデルの`attribute`で属性を指定することで、モデルの属性を SQL で取得したり、`ActiveRecord::Relation`の where メソッドに渡したりする方法をカスタマイズできる.

```ruby
create_table :store_listings, force: true do |t|
  t.decimal :price_in_cents
end
class StoreListing < ActiveRecord::Base
  attribute :price_in_cents, :integer
end
```

- `Sprockets 3`のサポート: Rails 5 では`app/assets/config/`ディレクトリ内の`manifest.js`で指定
- `Turbolinks 5`: `data-turbolinks-permanent`を DOM 要素につけることでページ間で保持されるようになり、状態の初期化を必要としないので、より高速に動作する. サイドバーなど、ページ間で固定の要素の場合は、`data-turbolinks-permanent`を付与し、ページ間で保持しない要素は、`data-turbolinks-temporary`をつけると良い
- `Rails API`: `ActionController::Base`の代わりに`ActionController::API`をコントローラで継承することによって、JSON API サーバー用の軽量な Rails アプリケーションを構築することができる。

### Controller/ View

- `render` メソッドは非常に単純なハッシュを引数に取ります。ハッシュのキーは`:plain`、ハッシュの値は `params[:article].inspect` です。`params` **メソッド**は、フォームから送信されてきたパラメータ (つまりフォームのフィールド) を表すオブジェクトです。`params` メソッドは `ActionController::Parameters` オブジェクトを返します。文字列またはシンボルを使って、このオブジェクトのハッシュのキーを指定できます。
- production (本番) 環境など、development 以外の環境に対してもマイグレーションを実行したい場合は、`rails db:migrate RAILS_ENV=production` のように環境変数を明示的に指定する必要があり
- `strong_parameters`: コントローラのアクションで本当に使ってよいパラメータだけを厳密に指定することを強制する. `params.require(:user).permit(:name, :email)` モデルに対する「`マスアサインメント`」が発生すると、正常なデータの中に悪意のあるデータが含まれてしまう可能性があるため。
- `コントローラの public メソッドは private より前に配置しないといけない。`
- 通常の変数ではなく、`インスタンス変数` ( @ を冒頭に付けることで示します) が使われている点に注目。これは、Rails ではコントローラのインスタンス変数はすべてビューに渡されるようになっているため(訳注: Rails はそのために背後でインスタンス変数をコントローラからビューに絶え間なくコピーし続けている)。
- `link_to`: 現在と同じコントローラのアクションにリンクする場合は、`:controller` の指定は不要。コントローラを指定しなければ、デフォルトで現在のコントローラが使われる。
- `pluralize`: 数値を受け取ってそれに応じて英語の「単数形/複数形」活用を行ってくれる Rails のヘルパーメソッド。数値が 1 より大きい場合は、引数の文字列を自動的に複数形に変更する。
- `scope: :article`のようにスコープにシンボルを指定すると、フィールドが空の状態で作成される。
- `パーシャルのファイル名`の先頭には`アンダースコア`を追加. (パーシャルファイルはフォームなど layout として使い回しができるファイルのことを言う)
- `article_path(@article)ヘルパー` → article id = XX の詳細画面へのパスを作成。

### Model

- `モデル`のクラス名が 2 語以上の複合語である場合、Ruby の慣習であるキャメルケース(CamelCase のように語頭を大文字にしてスペースなしでつなぐ)に従う。 (例: BookClub) 一方、`テーブル名/ スキーマ名`は(camel_case などのように)小文字かつアンダースコアで区切られなければならない。(例: book_clubs)
- `外部キー`: このカラムはテーブル名の単数形`_id` にする必要がある（例: item_id、order_id）
- type: モデルで Single Table Inheritance を使う場合に指定
- `関連付け名_type`: ポリモーフィック関連付けの種類を保存
- `テーブル名_count`: 関連付けにおいて、所属しているオブジェクトの数をキャッシュするのに使われる。たとえば、`Article` クラスに `comments_count` というカラムがあり、そこに `Comment` のインスタンスが多数あると、ポストごとのコメント数がここにキャッシュされる。
- `reversible`: マイグレーションを逆方向に実行 (ロールバック) する方法が推測できない場合に使う

```ruby
class ChangeProductsPrice < ActiveRecord::Migration[5.0]
  def change
    reversible do |dir|
      change_table :products do |t|
        dir.up { t.change :price, :string }
        dir.down { t.change :price, :integer }
      end
    end
  end
end
```

- change の代りに up と down がある. 処理が複雑なときは 変更前後をわけて記述すると良い。

```ruby
class ChangeProductsPrice < ActiveRecord::Migration[5.0]
  def up
    change_table :products do |t|
      t.change :price, :string
    end
  end

  def down
    change_table :products do |t|
      t.change :price, :integer
    end
  end
end
```

- マイグレーション名が `AddColumnToTable` や `RemoveColumnFromTable` で、かつその後ろにカラム名や型が続く形式になっていれば、適切な `add_column` 文や `remove_column` 文を含むマイグレーションが作成される。
- 例：`rails generate migration AddPartNumberToProducts part_number:string`

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :part_number, :string
  end
end
```

- マイグレーション名が`CreateXXX`のような形式であり、その後にカラム名と種類が続く場合、XXX という名前のテーブルが作成され、指定の種類のカラム名がその中に生成される。
- Add new column or option to the existing table:
  1. `rails generate migration add_role_to_user role:number`
  2. `rake db:migrate`
- カラムに変更を加える
- → description と name カラムを削除し、string カラムである part_number が作成されてインデックスをそこに追加。そして最後に upccode カラムをリネームする。

```ruby
change_table :products do |t|
  t.remove :description, :name
  t.string :part_number
  t.index :part_number
  t.rename :upccode, :upc_code
end
```

- change_column:
- → products テーブルの:name フィールドに NOT NULL 制約を設定し、:approved フィールドのデフォルト値を true から false に変更

```ruby
change_column_null :products, :name, false
change_column_default :products, :approved, from: true, to: false
```

- `外部キー`
- → 新たな外部キー を articles テーブルの author_id カラムに追加。このキーは authors テーブルの id カラムを参照する。欲しいカラム名をテーブル名から類推できない場合は、`:column` オプションと`:primary_key` オプションを使う。

```ruby
add_foreign_key :articles, :authors
```

- Active Record では単一カラムの外部キーのみがサポートされている。複合外部キーを使う場合は execute と structure.sql が必要。
- [`ブロックで change、change_default、remove が呼び出されない限り、change_table もロールバック可能`](https://railsguides.jp/active_record_migrations.html#change%E3%83%A1%E3%82%BD%E3%83%83%E3%83%89%E3%82%92%E4%BD%BF%E3%81%86)
- `reverse` で rollback 機能をそのまま活用することができる。
- `migrate`: 基本的にこれまで実行されたことのない`change`または`up`メソッドを実行
- `db:migrate` タスクを実行すると、`db:schema:dump コマンドも同時に呼び出される`。このコマンドは `db/schema.rb スキーマファイル`を更新し、スキーマがデータベースの構造に一致するようにする。
- `マイグレーションの特定のバージョン`を指定すると、Active Record は指定されたマイグレーションに達するまでマイグレーション (change/up/down) を実行する。マイグレーションのバージョンは、マイグレーションファイル名の冒頭に付いている数字. `rails db:migrate VERSION=20080906120000`　過去に遡るマイグレーションの場合、20080906120000 に到達するまでのすべてのマイグレーションの down メソッドを実行しますが、上と異なり、20080906120000 自身は`含まれない`点にご注意ください !!!
- `db:migrate:redo` コマンドは、`ロールバックと再マイグレーションを一度に実行`できるショートカット
- `db:setup` コマンドは、データベースの作成、スキーマの読み込み、シードデータを用いてデータベースの初期化を実行
- `db:reset` コマンドは、データベースを drop して再度設定する。このコマンドは `rails db:drop db:setup` と同等
- `特定のマイグレーション`を up または down 方向に実行する必要がある場合は、db:migrate:up または db:migrate:down を使用。`rails db:migrate:up VERSION=20080906120000` → 最初にそのマイグレーションが実行済みであるかどうかをチェックし、Active Record によって実行済みであると認定された場合は何も行わない。
- `既存のマイグレーションを変更`: マイグレーションをいったんロールバック (rails db:rollback など) してからマイグレーションを修正し、それから修正の完了したバージョンのマイグレーションを実行する.
  > そもそも、既存のマイグレーションを直接変更するのは一般的によくありません。既存のマイグレーションを変更すると、自分どころか共同作業者にまで余分な作業を強いることになります。さらに、既存のマイグレーションが本番環境で実行中の場合、ひどい頭痛の種になるでしょう。既存のマイグレーションを直接修正するのではなく、そのためのマイグレーションを新たに作成してそれを実行するのが正しい方法です。これまでコミットされてない (より一般的に言えば、これまで development 環境以外に展開されたことのない) マイグレーションを新たに生成し、それを編集するのが害の少ない方法であると言えます。`revert` メソッドは、以前のマイグレーション全体またはその一部を取り消すためのマイグレーションを新たに書くときにも便利です。
- `スキーマファイルの意味について`
  - Rails のマイグレーションは強力だが、データベースのスキーマを作成するための信頼できる情報源ではない。信頼できる情報源は、やはりデータベースである。Rails は、デフォルトでデータベーススキーマの最新の状態のキャプチャを試みる db/schema.rb を生成する。プリケーションのデータベースの新しいインスタンスを作成する場合、マイグレーションの全履歴を一から繰り返すよりも、`rails db:schema:load` でスキーマファイルを読み込む方が、高速かつエラーが起きにくい傾向がある!!!
  - スキーマ情報はモデルのコードの中にはない。スキーマ情報は多くのマイグレーションに分かれて存在しており、そのままでは非常に探しにくいものだが、この情報はスキーマファイルにコンパクトに収まっている。
- `スキーマダンプの種類`: Rails で生成されるスキーマダンプのフォーマットは、`config/application.rb` の `config.active_record.schema_format` 設定で制御されている。デフォルトのフォーマットは `:ruby` だが、`:sql` も指定できる。`:ruby` を指定すると、スキーマは `db/schema.rb` に保存される。
- db/schema.rb では、トリガ/シーケンス/ストアドプロシージャ/チェック制約などのデータベース固有の項目を表現できません。マイグレーションで execute を用いれば、Ruby マイグレーション DSL でサポートされないデータベース構造も作成できますが、そうしたステートメントはスキーマダンプで再構成されない → 新しいデータベースインスタンスの作成に有用なスキーマファイルを正確に得るためにスキーマのフォーマットを　`:sql` にする。`db/structure.sql` にダンプする。たとえば PostgreSQL の場合は pg_dump ユーティリティが使われる。MySQL や MariaDB の場合は、多くのテーブルにおいて SHOW CREATE TABLE の出力結果がファイルに含まれる。スキーマを `db/structure.sql` から読み込む場合、`rails db:structure:load` を実行
  > Active Record は、「知的に振る舞うのはモデルであり、データベースではない」というコンセプトに基づいている
- モデルに関連付けの:dependent オプションを指定すると、親オブジェクトが削除されたときに子オブジェクトも自動的に削除
  > `古いマイグレーション`: db/schema.rb や db/structure.sql は、使っているデータベースの最新ステートのスナップショットであり、そのデータベースを再構築するための情報源として信頼できます。このことを頼りにして、古いマイグレーションファイルを削除できます。db/migrate/ディレクトリ内のマイグレーションファイルを削除しても、マイグレーションファイルが存在していたときに rails db:migrate が実行されたあらゆる環境は、Rails 内部の `schema_migrations` という名前のデータベース内に保存されている（マイグレーションファイル固有の）`マイグレーションタイムスタンプへの参照を保持`し続けます。このテーブルは、`特定の環境でマイグレーションが実行されたことがあるかどうかをトラッキングする`のに用いられます。マイグレーションファイルを削除した状態で `rails db:migrate:status` コマンド（本来マイグレーションのステータス（up または down）を表示する）を実行すると、削除したマイグレーションファイルの後に`********** NO FILE **********`と表示されるでしょう。これは、そのマイグレーションファイルが特定の環境で一度実行されたが、db/migrate/ディレクトリの下に見当たらない場合に表示されます。

#### validation

- メソッドには、バリデーションをトリガするものと、しないものがある。この点に注意しておかないと、バリデーションが設定されているにもかかわらず、データベース上のオブジェクトが無効な状態になってしまう可能性がある。
- バリデーションのトリガが発生するもの：`create create! save save! update update!` `!`が末尾に付く`破壊的メソッド`(save!など)では、レコードが無効な場合に例外が発生。 `非破壊的なメソッド`は、無効な場合に例外を発生しない。`save と update` は無効な場合に `false` を返し、`create` は無効な場合に単にその`オブジェクトを返す`。
- `バリデーションのスキップ`: 次のメソッドはバリデーションを行わずにスキップする。オブジェクトの保存は、有効無効にかかわらず行われる。`decrement! decrement_counter increment! increment_counter toggle! touch update_all update_attribute update_column update_columns update_counters` 実は、save に `validate: false` を引数として与えると、save のバリデーションをスキップできてしまう。
- Rails は、Active Record オブジェクトを保存する`直前に`バリデーションを実行。バリデーションで何らかのエラーが発生すると、オブジェクトを保存しない。 `valid?`メソッドを使って、バリデーションを手動でトリガすることもできる。`valid?`を実行するとバリデーションがトリガされ、オブジェクトにエラーがない場合は `true` が返され、そうでなければ `false`が返される。
- バリデーション後、または valid? 後 `p.errors.messages` でエラーメッセージにアクセスできる。`Person.create.errors[:name].any? # => true`
- `acceptance`: フォームが送信されたときにユーザーインターフェイス上のチェックボックスがオンになっているかどうかを検証. `validates :terms_of_service, acceptance: { message: 'must be abided' }` :accept オプションも渡せる。このオプションは、「同意済み（accepted）」とみなす値を指定します。デフォルトは"1"ですが、変更は簡単. `validates :eula, acceptance: { accept: ['TRUE', 'accepted'] }`
- `validates_associated` を関連付けの両側のオブジェクトで実行しない。 関連付けの両側でこのヘルパーを使うと無限ループになる。
- `confirmation`: 2 つのテキストフィールドで受け取る内容が完全に一致する必要がある場合に使う。:case_sensitive オプションを用いて、大文字小文字の違いを確認する制約をかけるかどうかも定義できる。
- `exclusion`: 与えられた集合に属性の値が「含まれていない」ことを検証。集合には任意の enumerable オブジェクトが使える。`validates :subdomain, exclusion: { in: %w(www us ca jp), message: "%{value}は予約済みです" }` 逆は　`inclusion`
- `format`: with オプションで与えられた正規表現と属性の値がマッチするかどうかのテストによる検証. `validates :legacy_code, format: { with: /\A[a-zA-Z]+\z/, message: "英文字のみが使えます" }`
- `length`: 属性の値の長さを検証. `maximum, minimum, in, is` オプションがある。`:wrong_length、:too_long、:too_short` オプションがある。メッセージの単数複数には気を付ける。
- `numericality`: equal, greater_than, とか諸々ある。
- 関連付けられたレコードの存在が必須の場合、これを検証するには`:inverse_of` オプションでその関連付けを指定する必要がある。`has_many :line_items, inverse_of: :order`. `presence` の反対は `absence`
  > has_one または has_many リレーションシップを経由して関連付けられたオブジェクトが存在することを検証すると、blank?でもなく marked_for_destruction?(削除用マーク済み)でもないかどうかがチェックされます
- false.blank?は常に true なので、真偽値に対してこのメソッドを使うと正しい結果が得られない。真偽値の存在をチェックしたい場合は、`validates :field_name, inclusion: { in: [true, false] }`を使う必要がある。`validates :boolean_field_name, exclusion: { in: [nil] }`
- uniqueness: たまたま 2 つのデータベース接続によって同じ値を持つレコードが 2 つ作成される可能性があり、これを防ぐために使える。一意性チェックの範囲を限定する別の属性を指定する:scope オプションがある。`validates :name, uniqueness: { scope: :year, message: "発生は年に1度までである必要があります" }` `:case_sensitive` オプションもある。
- `validates_with`: バリデーション専用の別クラスにレコードを渡す!!!

```ruby
class GoodnessValidator < ActiveModel::Validator
  def validate(record)
    if record.first_name == "Evil"
      record.errors[:base] << "これは悪人だ"
    end
  end
end

class Person < ApplicationRecord
  validates_with GoodnessValidator
end
```

- or

```ruby
class GoodnessValidator < ActiveModel::Validator
  def validate(record)
    if options[:fields].any?{|field| record.send(field) == "Evil" }
      record.errors[:base] << "これは悪人だ"
    end
  end
end

class Person < ApplicationRecord
  validates_with GoodnessValidator, fields: [:first_name, :last_name]
end
```

- わりに素の Ruby オブジェクトを使うこともできる。

```ruby
class Person < ApplicationRecord
  validate do |person|
    GoodnessValidator.new(person).validate
  end
end

class GoodnessValidator
  def initialize(person)
    @person = person
  end

  def validate
    if some_complex_condition_involving_ivars_and_private_methods?
      @person.errors[:base] << "これは悪人だ"
    end
  end

  # ...
end
```

- `:allow_nil`: 対象の値が nil の場合にバリデーションをスキップ
- `:allow_blank`: 属性の値が blank?に該当する場合（nil や空文字など）にバリデーションがパス
- `:message`: 値には、`%{value}や%{attribute}や%{model}`をオプションで含められます。
- `:on` オプションは、バリデーション実行のタイミングを指定する。ビルトインのバリデーションヘルパーは、デフォルトでは`保存時`（`レコードの作成時および更新時の両方`）に実行される。バリデーションのタイミングを変更したい場合、on: :create を指定すればレコード新規作成時にのみ検証が行われ、on: :update を指定すればレコードの更新時にのみ検証が行われる。

##### 条件付きバリデーション

```ruby
class Order < ApplicationRecord
  validates :card_number, presence: true, if: :paid_with_card?

  def paid_with_card?
    payment_type == 'card'
  end
end
```

- proc を使った場合

```ruby
class Account < ApplicationRecord
  validates :password,
            confirmation: true, unless: Proc.new { |a| a.password.blank? }
end
```

- バリデーションをグループ化

```ruby
class User < ApplicationRecord
  with_options if: :is_admin? do |admin|
    admin.validates :password, length: { minimum: 10 }
    admin.validates :email, presence: true
  end
end
```

##### error message

- `errors[:base]`: 個別の属性に関連するエラーメッセージを追加する代りに、オブジェクトの状態全体に関連するエラーメッセージを追加することもできる。
- `errors.size`: エラーメッセージの総数

#### callback

> after_save コールバックは作成と更新の両方で呼び出されますが、コールバックマクロの呼び出し順にかかわらず、必ず、より詳細な after_create コールバックや after_update コールバックより 後 に呼び出されます。
> before_destroy コールバックは、dependent: :destroy よりも前に配置する（または prepend: true オプションを用いる）べきです

##### コールバックをスキップ

- 検証(validation)の場合と同様、以下のメソッドでコールバックをスキップできる。`decrement! decrement_counter delete delete_all increment! increment_counter update_column update_columns update_all update_counters`

#### Association

- 関連付けされた先のモデルの作成 → `@book = @author.books.create(published_at: Time.now)` → author_id は自動挿入される。
- `has_one`: その意味と結果は `belongs_to` とは若干異なる。`has_one` 関連付けの場合は、`その宣言が行われているモデルのインスタンスが、他方のモデルのインスタンスを「まるごと含んでいる」または「所有している」こと`を示している。たとえば、`供給者(supplier)1人につきアカウント(account)を1つだけ持つ`という関係がある。
- `has_one_through`: 2 つのモデルの間に「第 3 のモデル」(join モデル)が介在する。1 人の提供者(supplier)が 1 つのアカウントに関連付けられ、さらに 1 つのアカウントが 1 つのアカウント履歴に関連付けられる場合
- `has_many_through`: 2 つのモデルの間に「第 3 のモデル」(join モデル)が介在する。患者(patient)が医師(physician)との診察予約(appointment)を取る医療業務
- `has_and_belongs_to_many`: 「第 3 のモデル」(join モデル)が介在しない。アプリケーションに完成品(assembly)と部品(part)があり、1 つの完成品に多数の部品が対応し、逆に 1 つの部品にも多くの完成品が対応する場合。
- `belongs_toとhas_oneのどちらを選ぶか?`:2 つのモデルの間に 1 対 1 の関係を作りたいのであれば、いずれか一方のモデルに belongs_to を追加し、もう一方のモデルに has_one を追加する必要がある。区別の決め手となるのは外部キー(foreign key)をどちらに置くか(外部キーは、belongs_to を追加した方のモデルのテーブルに追加される)。
- マイグレーションで t.bigint :supplier_id のように「小文字のモデル名\_id」と書くと、外部キーを明示的に指定できる。現在のバージョンの Rails では、同じことを `t.references :supplier` という方法で記述できる。こちらの方が実装の詳細が抽象化され、隠蔽される。
- `has_many :throughとhas_and_belongs_to_manyのどちらを選ぶか?` リレーションシップのモデルそれ自体を独立したエンティティとして扱いたい(両モデルの関係そのものについて処理を行いたい)のであれば、中間に join モデルを使う has_many :through リレーションシップを選ぶのが最もシンプル。`リレーションシップのモデルで何か特別なことをする必要がまったくないのであれば`、join モデルの不要な has_and_belongs_to_many リレーションシップを使うのがシンプルです(ただし、こちらの場合は join モデルが不要な代わりに、専用の join テーブルを別途データベースに作成しておく必要があるので、お忘れなきよう)。
- polymorphic relationship には、`t.references :imageable, polymorphic: true` とすると楽。
- [`自己結合`](https://railsguides.jp/association_basics.html#%E8%87%AA%E5%B7%B1%E7%B5%90%E5%90%88): 授業員テーブルがあり、manager と subordinates の関連付けをしたい場合。

#### ヒントと注意事項

1. キャッシュ制御: モデルインスタンスを取得した時のデータになるため、他で更新された時のデータより古い物になる可能性がある。→ reload を使用。`author.books.reload.empty?`
2. 名前衝突の回避: ActiveRecord::Base のインスタンスで既に使われているような名前を関連付けに使うのは禁物。`attributes` や `connection`は関連付けに使ってはならない
3. スキーマの更新, has_and_belongs_to_many 関連付けに対応する join テーブルを作成: このテーブルはモデルを表さないので、`create_table`に`id: false`を渡す。こうしておかないとこの関連付けは正常に動かない。

```ruby
class Assembly < ApplicationRecord
  has_and_belongs_to_many :parts
end

class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies
end

class CreateAssembliesPartsJoinTable < ActiveRecord::Migration[5.0]
  def change
    create_table :assemblies_parts, id: false do |t|
      t.bigint :assembly_id
      t.bigint :part_id
    end

    add_index :assemblies_parts, :assembly_id
    add_index :assemblies_parts, :part_id
  end
end
```

4. 関連付けのスコープ制御: デフォルトでは、関連付けによって探索されるオブジェクトは、現在のモジュールのスコープ内のものだけ。以下の実装はスコープが別なので動かない。

```ruby
module MyApplication
  module Business
    class Supplier < ApplicationRecord
      has_one :account
    end
  end

  module Billing
    class Account < ApplicationRecord
      belongs_to :supplier
    end
  end
end
```

- 次のようにスコープを指定して関連付けを行う。

```ruby
module MyApplication
  module Business
    class Supplier < ApplicationRecord
      has_one :account, class_name: 'MyApplication::Billing::Account'
    end
  end

  module Billing
    class Account < ApplicationRecord
      belongs_to :supplier, class_name: 'MyApplication::Business::Supplier'
    end
  end
end
```

5.  双方向関連付け: Active Record では標準的な名前同士の関連付けのほとんどをサポートしていて、自動的に認識できる。ただ、テーブル名とそのクラス名を指定してるプロパティー名が違う時、例えば、Author テーブルを Book テーブルで writer プロパティとして使いたいときは、自動認識できない。→ `inverse_of` を使う。

```ruby
class Author < ApplicationRecord
  has_many :books, inverse_of: 'writer'
end

class Book < ApplicationRecord
  belongs_to :writer, class_name: 'Author', foreign_key: 'author_id'
end
```

##### 関連付けの詳細情報

- belongs_to 関連付けの詳細: 自動的に利用できる 6 つのメソッド。`association, association=(associate), build_association(attributes = {}), create_association(attributes = {}), create_association!(attributes = {}), reload_association` association の部分はプレースホルダ。`build → 初期化 create → 初期化 + 保存`
  > 新しく作成した has*one 関連付けまたは belongs_to 関連付けを初期化するには、build*で始まるメソッドを使う必要があります。この場合 has*many 関連付けや has_and_belongs_to_many 関連付けで使われる association.build メソッドは使わないでください。作成するには、create*で始まるメソッドをお使いください。
  - association=(associate): association=メソッドは、引数のオブジェクトをそのオブジェクトに関連付ける。
- `:counter_cache` : 従属しているオブジェクトの数の検索効率を向上
- `:optional`: オプションを true に設定すると、関連付けされたオブジェクトの存在性のバリデーションが実行されないようになる。
- `belongs_toのスコープ`, `includes`: その関連付けが使われるときに `eager-load` (訳注: `preload`とは異なる)しておきたい第 2 関連付けを指定。単純に joins または left_outer_joins を使用して取得しても`関連オブジェクト`も取得できる。

```ruby
class Chapter < ApplicationRecord
  belongs_to :book
end

class Book < ApplicationRecord
  belongs_to :author
  has_many :chapters
end

class Author < ApplicationRecord
  has_many :books
end
```

- chapters から著者名(Author)を `@chapter.book.author` のように直接取り出す頻度が高い場合は、chapter から book への関連付けを行なう時に Author をあらかじめ includes しておくと、無駄なクエリが減って効率が高まる。

```ruby
class Chapter < ApplicationRecord
  belongs_to :book, -> { includes :author }
end
```

- `Article.includes(:category, :comments)` → category, comment の他のアソシエーションも取ってくる
- `Category.includes(articles: [{ comments: :guest }, :tags]).find(1)` → id=1 のカテゴリを検索し、関連付けられたすべての記事とそのタグやコメント、およびすべてのコメントのゲスト関連付けを一括読み込み

- `has_many 関連付けにオブジェクトをアサインし`、しかもそのオブジェクトを保存`したくない`場合、`collection.build` メソッドを使う。
- `関連付けの拡張`: `無名モジュール`( `anonymous module`)を用いる

```ruby
class Author < ApplicationRecord
  has_many :books do
    def find_by_book_prefix(book_number)
      find_by(category_id: book_number[0..2])
    end
  end
end
```

- 名前付きの拡張モジュールを使う場合（拡張をさまざまな関連付けで共有したい）。

```ruby
module FindRecentExtension
  def find_recent
    where('created_at > ?', 5.days.ago)
  end
end

class Author < ApplicationRecord
  has_many :books, -> { extending FindRecentExtension }
end

class Supplier < ApplicationRecord
  has_many :deliveries, -> { extending FindRecentExtension }
end
```

- `シングルテーブル継承 （STI）`: `rails generate model vehicle type:string color:string price:decimal{10.2}` type を必ず指定。これを継承するときは、parent オプションで指定。　`rails generate model car --parent=Vehicle` `Car.all` で自動で type = Car がセットされたクエリーが発行される。

#### クエリーインターフェース

- 検索メソッドは where や group といったコレクションを返したり、`ActiveRecord::Relation` のインスタンスを返す。また、find や first などの`１つのエンティティ`を検索するメソッドの場合、その`モデルのインスタンス`を返す。
- `find` で複数検索 `clients = Client.find([1, 10])`
- `find_by` で任意のキーで検索 `Client.find_by first_name: 'Lifo'` これは `Client.where(first_name: 'Lifo').take` と等価。
- `find_by!` メソッドの動作は、マッチするレコードが見つからない場合に `ActiveRecord::RecordNotFound例外`が発生する
  > Rails では、メモリを圧迫しないサイズにバッチを分割して処理するための方法を 2 とおり提供しています。1 つ目は find_each メソッドを使用する方法です。これは、レコードのバッチを 1 つ取り出し、次に、各レコードを 1 つのモデルとして個別にブロックに yield します。2 つ目の方法は find_in_batches メソッドを使用する方法です。レコードのバッチを 1 つ取り出し、次にバッチ全体をモデルの配列としてブロックに yield します。

> find_each 　メソッドと　 find_in_batches 　メソッドは、一度にメモリに読み込めないような大量のレコードに対するバッチ処理のためのものです。数千のレコードに対して単にループ処理を行なうのであれば通常の検索メソッドで十分です。

- find_each: 複数のレコードを一括で取り出し、続いて 各 レコードを 1 つのブロックに yield。以下の例では、find_each でバッチから 1000 件のレコードを一括で取り出し、各レコードをブロックに yield。
- `batch_size:` で一度に取り出す量を指定。

```ruby
User.find_each { |user| NewsMailer.weekly(user).deliver_now }
```

- find_in_batches: バッチ を**個別にではなく** `モデルの配列として`ブロックに yield する。

```ruby
# 1回あたり add_invoices に納品書1000通の配列を渡す
Invoice.find_in_batches do |invoices|
  export.add_invoices(invoices)
end
```

- where は文字列ではなく配列を使って構築する。`Client.where("orders_count = ? AND locked = ?", params[:orders], false)`　これは SQL Injection の危険性がある `Client.where("orders_count = #{params[:orders]}")`
- where + ハッシュ引数　`Client.where("created_at >= :start_date AND created_at <= :end_date", {start_date: params[:start_date], end_date: params[:end_date]})`
- `等値条件`指定が直感的にできる。
  `Client.where(locked: true)` ハッシュにする
  `Client.where('locked' => true)` 文字列形式にする
  `Article.where(author: author)` オブジェクトを渡すこともできる。
- `BETWEEN` を表現するための `..` (範囲条件) → `Client.where(created_at: (Time.now.midnight - 1.day)..Time.now.midnight)`
- `IN` を表現する → 条件ハッシュにそのための配列を 1 つ渡す
- `NOT` → `Client.where.not(locked: true)`
- only メソッドで、条件を上書できる。`Article.where('id > 10').limit(20).order('id desc').only(:order, :where)` → :order と :where 条件のみ適用。
- `Nullリレーション`: `Article.none` []または nil を返すと、このコード例では呼び出し元のコードを壊してしまうため。

##### レコードを更新できないようロックする
- ロックは、データベースのレコードを更新する際の`競合状態を避け`、`アトミックな` (=`中途半端な状態のない`) 更新を行なうために有用です。
- `楽観的ロック (optimistic)`: レコードがオープンされてから変更されたことがあるかどうかをチェック。そのような変更が行われ、かつ更新が無視された場合、`ActiveRecord::StaleObjectError` 例外が発生.
- 楽観的ロックを使用するには、テーブルに lock_version という名前の integer 型カラムがある必要がある。Active Record は、レコードが更新されるたびに lock_version カラム の値を 1 ずつ増やします。更新リクエストが発生したときの lock_version の値がデータベース上の lock_version カラムの値よりも小さい場合、更新リクエストは失敗し、ActiveRecord::StaleObjectError エラーが発生する。
- ActiveRecord::Base には、lock_version カラム名を上書きするための locking_column が用意されている。`self.locking_column = :lock_client_column`
- `悲観的ロック`: データベースが提供するロック機構を使用。リレーションの構築時に lock を使用すると、選択した行に対する排他的ロックを取得できる。lock を使用するリレーションは、デッドロック条件を回避するために通常トランザクションの内側にラップされる。

```ruby
Item.transaction do
  i = Item.lock.first
  i.name = 'Jones'
  i.save!
end
```

- モデルのインスタンスが既にある場合は、トランザクションを開始してその中でロックを一度に取得できる。

```ruby
item = Item.first
item.with_lock do
  # このブロックはトランザクション内で呼び出される
  # itemはロック済み
  item.increment!(:views)
end
```

##### 結合
- ネストした関連付けを結合する (単一レベル)　`Article.joins(comments: :guest)` は次のような SQL が発行される。

```sql
SELECT articles.* FROM articles
  INNER JOIN comments ON comments.article_id = articles.id
  INNER JOIN guests ON guests.comment_id = comments.id
  # 「ゲストによるコメントが1つある記事をすべて返す」
```

- ネストした関連付けを結合する (複数レベル) `Category.joins(articles: [{ comments: :guest }, :tags])`

```sql
SELECT categories.* FROM categories
  INNER JOIN articles ON articles.category_id = categories.id
  INNER JOIN comments ON comments.article_id = articles.id
  INNER JOIN guests ON guests.comment_id = comments.id
  INNER JOIN tags ON tags.article_id = articles.id
```

- `結合されたテーブルで条件を指定する`

```ruby
time_range = (Time.now.midnight - 1.day)..Time.now.midnight
Client.joins(:orders).where('orders.created_at' => time_range)
```

- 上記の where よりもさらにわかりやすい方法 → ハッシュ条件をネスト化する。

```ruby
time_range = (Time.now.midnight - 1.day)..Time.now.midnight
Client.joins(:orders).where(orders: { created_at: time_range })
```

- `関連レコードがあるかどうかにかかわらずレコードのセットを取得したい場合` → `left_outer_joins` 関連レコードがあるときのみ → `joins` (INNER JOIN)

##### スコープ
- 以下のようにスコープを作成すると、`Article.published`にして手軽に特定の条件下のデータを取得することができる。
```ruby
class Article < ApplicationRecord
  scope :published, -> { where(published: true) }
end
# 引数を渡す
class Article < ApplicationRecord
  scope :created_before, ->(time) { where("created_at < ?", time) }
end
```
- これは以下のコードと等価
```ruby
class Article < ApplicationRecord
  def self.published
    where(published: true)
  end
end
```
- スコープをスコープ内で `チェイン (chain)` させることもできる。
```ruby
class Article < ApplicationRecord
  scope :published,               -> { where(published: true) }
  scope :published_and_commented, -> { published.where("comments_count > 0") }
end
```
> 条件文を評価した結果がfalseになった場合であっても、スコープは常にActiveRecord::Relationオブジェクトを返すという点です。クラスメソッドの場合はnilを返すので、この振る舞いが異なります。したがって、条件文を使ってクラスメソッドをチェインさせていて、かつ、条件文のいずれかがfalseを返す場合、NoMethodErrorを発生することがあります。
- `デフォルトスコープを適用`: あるスコープをモデルのすべてのクエリに適用したい場合、モデル自身の内部でdefault_scopeメソッドを使用することができる。→ Laravel の global scope と等価。
- `スコープのマージ`: 
```ruby
class User < ApplicationRecord
  scope :active, -> { where state: 'active' }
  scope :inactive, -> { where state: 'inactive' }
end

User.active.inactive
# SELECT "users".* FROM "users" WHERE "users"."state" = 'active' AND "users"."state" = 'inactive'
```
- 何らかの理由でスコープをすべて解除したい → `unscoped`

##### Other things
- `動的検索`: テーブルに定義されたすべての`フィールド` (`属性`とも呼ばれます) に対して自動的に検索メソッドを提供する。たとえば、Clientモデルに　first_name というフィールドがあると、`find_by_first_name` というメソッドが Active Record によって自動的に作成される。Client モデルに locked というフィールドがあれば、`find_by_locked` というメソッドを使用できる。name と locked の両方を検索したいのであれば、2つのフィールド名をandでつなぐ。`Client.find_by_first_name_and_locked("Ryan", true)`
- `enumマクロ`: 整数のカラムを設定可能な値の集合にマッピング
```ruby
class Book < ApplicationRecord
  enum availability: [:available, :unavailable]
end

# 下の両方の例で、利用可能な本を問い合わせている
Book.available
# または
Book.where(availability: :available)

book = Book.new(availability: :available)
book.available?   # => true
book.unavailable! # => true
book.available?   # => false
```
- `Client.create_with(locked: false).find_or_create_by(first_name: 'Andy')` は次にコードと等価。
```ruby
Client.find_or_create_by(first_name: 'Andy') do |c|
  c.locked = false
end
```
- `find_or_initialize_by`メソッドは create の代りに new を呼ぶ。つまり、モデルの新しいインスタンスは作成されるが、その時点ではデータベースに保存されない。
- pluck:
```ruby
class Client < ApplicationRecord
  def name
    "私は#{super}"
  end
end

Client.select(:name).map &:name
# => ["私はDavid", "私はJeremy", "私はJose"]

Client.pluck(:name)
# => ["David", "Jeremy", "Jose"]
```
- `many?` :Returns true if there is more than one record.
- リレーションによってトリガされるクエリでEXPLAINを実行することができる。 `User.where(id: 1).joins(:articles).explain`