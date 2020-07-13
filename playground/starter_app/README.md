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

### ヘルパー

#### Controller/ View

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

#### Model

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
