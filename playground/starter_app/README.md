### TOC

<!-- TOC -->

        - [TOC](#toc)
        - [Many things..](#many-things)
        - [Controller](#controller)
            - [パラメータの基本ルール:](#パラメータの基本ルール)
            - [Route](#route)
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
            - [Connect multiple dbs](#connect-multiple-dbs)
            - [Active Model](#active-model)
        - [Action View](#action-view)
            - [テンプレート](#テンプレート)
            - [パーシャル (部分テンプレート)](#パーシャル-部分テンプレート)
            - [ビューのパス](#ビューのパス)
            - [Helpers](#helpers)
            - [FormHelper](#formhelper)
            - [FormTagHelper](#formtaghelper)
            - [ローカライズされたビュー](#ローカライズされたビュー)
            - [render, rendering](#render-rendering)
            - [form](#form)
        - [Active Support](#active-support)
            - [安全な文字列](#安全な文字列)
        - [Storage](#storage)
        - [Command Line Tool](#command-line-tool)
        - [アセットパイプライン (Sprockets がファイルをまとめるまでの工程)](#アセットパイプライン-sprockets-がファイルをまとめるまでの工程)
            - [Autoload](#autoload)
        - [Cache: how to cache view template and records for better performance](#cache-how-to-cache-view-template-and-records-for-better-performance)
        - [Instrumentation API](#instrumentation-api)
        - [Rails を API として使う](#rails-を-api-として使う)
- [Nginx](#nginx)

<!-- /TOC -->

### Many things..
- `レシーバ`: インスタンスメソッドを利用するインスタンス自身のこと
```ruby
re = "9"
# 以下の式のレシーバは str
re.to_i #=> 9
```
- `self`: model クラスの中でメソッドを定義する際に、メソッド名の頭に`self.`を付けると`クラスメソッド` 付けないと`インスタンスメソッド``
  - `メソッド内でselfを使用する場合`: クラスメソッド内で self を使うと`クラス`を指し、インスタンスメソッド内で self はその`インスタンス`になる
- Hashes are indexed using the square brackets (`[]`) and accessing either the `string literal` you used for the key, or the `symbol`.
- `シンボル`（`:`）: 同じオブジェクトとして扱いたい場合に使う。（= 複数あると困るものに使う。つまりハッシュのキー）[ref](https://uxmilk.jp/25934)
```ruby
ms_suzuki = "Yoshiko"
ms_takahashi = "Yoshiko"
ms_suzuki.equal? ms_takahashi
=> false
# シンボルを使うとシングルトンオブジェクトをアサインできる
ms_suzuki = :Yoshiko
ms_takahashi = :Yoshiko
ms_suzuki.equal? ms_takahashi
=> true
#重複して困るものにはシンボルを採用する
our_name= { :my_name => 'Ahiru', :his_name => 'Kitsune', :my_nephew => 'Yamori' }
p our_name[:my_name]
```
- ruby のハッシュの宣言方法
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

- `a ||= b` is equivalent to `a || a = b`. not same as `a = a || b` `@_current_user ||= session[:current_user_id] && User.find_by(id: session[:current_user_id])`

### Controller
- コントローラの命名規則: 名前の最後の部分に`「複数形」`(モデルの命名規則は`「単数形」`であることが期待される)
- `new メソッド`の内容が空であるにもかかわらず正常に動作する。これは、Rails では `new アクション`で特に指定のない場合には `new.html.erb` ビューをレンダリングするため。
- コントローラで`default_url_options`という名前のメソッドを定義すると、URL生成用のグローバルなデフォルトパラメータを設定できる。`ActionController::Base` で定義すれば全ての Controller に適用される。
- `render` メソッドは非常に単純なハッシュを引数に取ります。ハッシュのキーは`:plain`、ハッシュの値は `params[:article].inspect` です。`params` **メソッド**は、フォームから送信されてきたパラメータ (つまりフォームのフィールド) を表すオブジェクトです。`params` メソッドは `ActionController::Parameters` オブジェクトを返します。文字列またはシンボルを使って、このオブジェクトのハッシュのキーを指定できます。
- production (本番) 環境など、development 以外の環境に対してもマイグレーションを実行したい場合は、`rails db:migrate RAILS_ENV=production` のように環境変数を明示的に指定する必要があり
- `strong_parameters`: コントローラのアクションで本当に使ってよいパラメータだけを厳密に指定することを強制する. `params.require(:user).permit(:name, :email)` モデルに対する「`マスアサインメント`」が発生すると、正常なデータの中に悪意のあるデータが含まれてしまう可能性があるため。
- Controller のメソッドで（update など）で postfix(!) required な params が無い場合、400 コードを返して例外を返すことができる。[ref](https://railsguides.jp/action_controller_overview.html#strong-parameters)
- 「params の値には許可されたスカラー値の配列を使わなければならない」ことを宣言するには、キーに空の配列を対応付ける。`params.permit(id: [])`
- `ネストしたパラメータ`: permit にネストした物を渡すことができる。
```ruby
params.permit(:name, { emails: [] },
              friends: [ :name,
                         { family: [ :name ], hobbies: [] }])
```  
- `コントローラの public メソッドは private より前に配置しないといけない。`
#### パラメータの基本ルール:
- 重複したパラメータ名は無視される。
- パラメータ名に空の角かっこ`[ ]`が含まれている場合、パラメータは配列の中にまとめられる。
```ruby
<input name="person[phone_number][]" type="text"/>
<input name="person[phone_number][]" type="text"/>
<input name="person[phone_number][]" type="text"/>
# => params[:person][:phone_number]が電話番号の配列
```
```ruby
<input name="addresses[][line1]" type="text"/>
<input name="addresses[][line2]" type="text"/>
<input name="addresses[][city]" type="text"/>
# => params[:addresses]ハッシュが作成される
```
- `フィールドを動的に追加する`: 残念ながらRailsではこのためのビルトインサポートは用意されていない。フィールドセットをその場で生成する場合は、関連する配列のキーが重複しないよう注意する。これには、JavaScript で現在の日時を取得して数ミリ秒の時差から一意の値を得るのが定番。
- `flash` の値を別のリクエストにも引き継ぎたい場合は、`keep`メソッドを使う。
```ruby
class MainController < ApplicationController
  def index
    # すべてのflash値を保持する
    flash.keep
    # flash.keep(:notice)
    redirect_to users_url
  end
end
```
- `flash.now`: デフォルトでは、flash に値を追加すると`直後のリクエスト`でその値を利用できるが、次のリクエストを待たずに同じリクエスト内でこれらの flash 値にアクセスしたい場合がある。たとえば、create アクションに失敗してリソースが保存されなかった場合に、new テンプレートを直接描画するとする。このとき新しいリクエストは行われないが、この状態でも flash を使ってメッセージを表示したい。このような場合、`flash.now` を使えば通常の `flash` と同じ要領でメッセージを表示できる。
- セッションを削除する場合は`キーに nil を指定`することで削除。cookie を削除する場合は`cookies.delete(:key)`を使う。
- `フィルタ`: コントローラにあるアクションの「直前 (before)」、「直後 (after)」、あるいは「直前と直後の両方 (around)」に実行されるメソッド. フィルタは継承される.
- `skip_before_action メソッド`: 特定のアクションでフィルタをスキップできる。
- `csrf 対策`: form ヘルパーを使わず手作りした場合や、別の理由でトークンが必要な場合には、`form_authenticity_token`メソッドでトークンを生成できる。
- `ActiveRecord::RecordNotFound エラー`は、production 環境ではすべて404エラーページが表示されるため、この振る舞いをカスタマイズする必要がない限り、開発者がこのエラーを扱う必要は無い。
- `HTTPSプロトコルを強制する`: コントローラとのやりとりがHTTPSのみで行われるようにしたい場合は、環境設定の`config.force_ssl`で`ActionDispatch::SSL`ミドルウェアを有効にすることで行うべき。

#### Route
- Rails のルーターは受け取った URL を認識し、適切なコントローラ内アクションや Rack アプリケーションに割り当てる。
- `複数のリソース`を同時に定義: `resources :photos, :books, :videos`
- `単数形リソース`: `get 'profile', to: 'users#show'`
- `resource` と `resources` は割り当てが異なるので注意
- 複数形リソースの場合と同様に、単数形リソースでも _path ヘルパーに対応する _url ヘルパーが使える。_url ヘルパーは、_path の前に現在のホスト名、ポート番号、パスのプレフィックスが追加されている点が異なる。
- コントローラの名前空間とルーティング: /admin/* にアクセスした時に /Admin 配下の Controller (Admin::ArticlesController) を探す。
```ruby
namespace :admin do
  resources :articles, :comments
end
```
- (/adminが前についていない) `/articles` を Admin::ArticlesController にルーティングしたい場合 `resources :articles, module: 'admin'` またはブロックで書いた場合、
```ruby
scope module: 'admin' do
  resources :articles, :comments
end
```
- `/admin/articles` を (Admin::なしの) ArticlesControllerにルーティングしたい場合 `resources :articles, path: '/admin/articles'` またはブロックで書いた場合、
```ruby
scope '/admin' do
  resources :articles, :comments
end
```
- `ネストしたリソース`: ヘルパーは `magazine_ads_url` や `edit_magazine_ad_path` のような名前になる。[ref](https://railsguides.jp/routing.html#%E3%83%8D%E3%82%B9%E3%83%88%E3%81%97%E3%81%9F%E3%83%AA%E3%82%BD%E3%83%BC%E3%82%B9)
```ruby
class Magazine < ApplicationRecord
  has_many :ads
end

class Ad < ApplicationRecord
  belongs_to :magazine
end
```
```ruby
resources :magazines do
  resources :ads
end
```
- `「浅い」ネスト`: id などを url に含まない（index/new/createのような idを必要としないアクション）`verb` のみをネスト化する。これによりコレクションだけが階層化のメリットを受けられる。(`/publishers/1/magazines/2/photos/3`のような深いネストを回避)
```ruby
resources :articles do
  resources :comments, only: [:index, :new, :create]
end
resources :comments, only: [:show, :edit, :update, :destroy]
```
- または `shallow オプション`を使用
```ruby
resources :articles do
  resources :comments, shallow: true
end
```
- DSL (ドメイン固有言語) である `shallow メソッド` をルーティングで使うと、すべてのネストが浅くなるように内側にスコープを1つ作成する。
```ruby
shallow do
  resources :articles do
    resources :comments
    resources :quotes
    resources :drafts
  end
end
```
- `scope メソッド` には、「浅い」ルーティングをカスタマイズするためのオプションが2つある。深くなるネストの url に追加するか、helper に追加するかの２種類
1. `:shallow_path オプション`: ex. get path => `/sekret/comments/:id(.:format)`
```ruby
scope shallow_path: "sekret" do
  resources :articles do
    resources :comments, shallow: true
  end
end
```
2. `:shallow_prefix オプション`: ex. get helper => `sekret_comment_path`
```ruby
scope shallow_prefix: "sekret" do
  resources :articles do
    resources :comments, shallow: true
  end
end
```
- `routing concern`: concern を使うことで、他のリソースやルーティング内で使いまわせる共通のルーティングを宣言できる。concern はルーティング内のどの場所にでも配置できる。
- `オブジェクトからパスとURLを作成`: id を渡す代わりに `<%= link_to 'Ad details', magazine_ad_path(@magazine, @ad) %>` とする
- `url_for` を使うとシンプルになる: `<%= link_to 'Ad details', url_for([@magazine, @ad]) %>`
- もっとシンプルな方法: `<%= link_to 'Ad details', [@magazine, @ad] %>`
- それ以外のアクションであれば、配列の最初の要素にアクション名を挿入: `<%= link_to 'Edit Ad', [:edit, @magazine, @ad] %>`
- `RESTful なルーティングにメンバーを追加`:
1. `メンバー (member) ルーティング`
```ruby
resources :photos do
  member do
    get 'preview'
  end
end
```
> 上のルーティングは GET リクエストとそれに伴う /photos/1/preview を認識し、リクエストを Photos コントローラの preview アクションにルーティングし、リソース id 値を params[:id] に渡します。同時に、preview_photo_url ヘルパーと preview_photo_path ヘルパーも作成されます
2. `コレクションルーティング`
```ruby
resources :photos do
  collection do
    get 'search'
  end
end
```
> 上のルーティングは、GETリクエスト+/photos/searchなどの (idを伴わない) パスを認識し、リクエストをPhotosコントローラのsearchアクションにルーティングします。このときsearch_photos_urlやsearch_photos_pathルーティングヘルパーも同時に作成されます。

> 第1引数として resource ルーティングをシンボルで定義する場合は、文字列で定義した場合と同等ではなくなる点にご注意ください。文字列はパスとして推測されますが、シンボルはコントローラのアクションとして推測されます。
- `名前付きルーティング`: `:as`オプションを使う `get 'exit', to: 'sessions#destroy', as: :logout` `logout_path` を呼び出すと `/exit` が返される。
- `HTTP動詞を制限する`: `match` メソッドと `:via` オプションを使うことで、複数の HTTP 動詞に同時にマッチするルーティングを作成できる。`match 'photos', to: 'photos#show', via: [:get, :post]`
- `セグメントを制限`: `get 'photos/:id', to: 'photos#show', constraints: { id: /[A-Z]\d{5}/ }` 
- `ルーティンググロブとワイルドカードセグメント`: ルーティンググロブ (route globbing) とはワイルドカード展開のことであり、ルーティングのある位置から下のすべての部分に特定のパラメータをマッチさせる際に使う。 `get 'photos/*other', to: 'photos#unknown'` `get '*a/foo/*b', to: 'test#index'` とすると `params[:a]` のようにマッチした動的セグメントを取り出すことができる。
- `使うコントローラを指定`: `resources :photos, controller: 'images'` 名前空間内のコントローラの場合は、`resources :user_permissions, controller: 'admin/user_permissions'`
- `newセグメントやeditセグメントをオーバーライド`: `resources :photos, path_names: { new: 'make', edit: 'change' }` このオプションによる変更をすべてのルーティングに統一的に適用したくなった場合は、スコープを使う。
```ruby
scope path_names: { new: 'make' } do
  # 残りすべてのルーティング
end
```
- `名前付きルーティングヘルパーにプレフィックスを追加`
```ruby
scope 'admin' do
  resources :photos, as: 'admin_photos'
end
# => admin_photos_path や new_admin_photo_path などのルーティングヘルパーを生成
```
- `ルーティングヘルパーのグループにプレフィックスを追加`: `scope メソッド`で `:as オプション`を使う。
```ruby
scope 'admin', as: 'admin' do
  resources :photos, :accounts
end

resources :photos, :accounts
# => admin_photos_path と admin_accounts_path などのルーティングを生成。これらは /admin/photos と /admin/accounts にそれぞれ割り当てられる。
```
- `パスを変更`: 
```ruby
scope(path_names: { new: 'neu', edit: 'bearbeiten' }) do
  resources :categories, path: 'kategorien'
end
```
- `「単数形のフォーム」をオーバーライド`:  
```ruby
ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'tooth', 'teeth'
end
```
- `名前付きルーティングのパラメータをオーバーライド`: ex id => identifier
```ruby
# routes
resources :videos, param: :identifier

# Controller
Video.find_by(identifier: params[:identifier])
```
- routes の確認: `http://localhost:3000/rails/info/routes` をブラウザで開く。または、ターミナルで `rails routes --expanded` コマンド `-g（grepオプション）`を使ってルーティングを検索 `$ rails routes -g POST` 特定のコントローラに対応するルーティングだけを表示したい場合は、`-c オプション` => `$ rails routes -c users`



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

#### Connect multiple dbs
- [複数の DB を使う](https://tech.dely.jp/entry/rails6_multiple_db#%E8%A4%87%E6%95%B0%E3%83%87%E3%83%BC%E3%82%BF%E3%83%99%E3%83%BC%E3%82%B9%E3%81%AE%E4%BB%95%E7%B5%84%E3%81%BF)
- 現時点でサポートされている機能：
  1. 複数の「primary」データベースと、それぞれに対応する1つの「replica」
  2. モデルでのコネクション自動切り替え
  3. HTTP verbや直近の書き込みに応じた primary と replica の自動スワップ
  4. マルチプルデータベースの作成、削除、マイグレーション、やりとりを行うRailsタスク
   
- サポートされていない機能：
  1. シャーディング（sharding）
  2. クラスタを越える JOIN
  3. replica のロードバランシング
  4. マルチプルデータベースのスキーマキャッシュのダンプ

#### Active Model
- `Action Pack` ヘルパーは、Active Model のおかげで`非Active Record`モデルとやりとりすることができる。Active Model　を使用することで、カスタムのORM (オブジェクトリレーショナルマッピング) を作成して　Rails　フレームワークの外で使用することもできる。
- `include ActiveModel::AttributeMethods` → クラスのメソッドにカスタムのプレフィックスやサフィックスを追加
- `ActiveModel::Callbacks`　→ Active Record スタイルのコールバックを提供
- クラスで `persisted?` メソッドと` id メソッド`が定義されていれば、`ActiveModel::Conversion` モジュールをインクルードして Rails の変換メソッドをそのクラスのオブジェクトに対して呼び出すことができる。
- `ActiveModel::Dirty` モジュールを → オブジェクトで変更が生じたかどうかを検出できる。
```ruby
# 元の値から変更された属性のハッシュを返す
person.changed_attributes # => {"first_name"=>nil}

# 変更のハッシュを返す (ハッシュのキーは属性名、ハッシュの値はフィールドの新旧の値の配列
person.changes # => {"first_name"=>[nil, "First Name"]}
```
- `ActiveModel::Validations` → クラスオブジェクトをActive Recordスタイルで検証できる
- `ActiveModel::Naming` → 命名やルーティングの管理を支援するクラスメソッドを多数追加
```ruby
Person.model_name.name                # => "Person"
Person.model_name.singular            # => "person"
Person.model_name.plural              # => "people"
```
- `ActiveModel::Model` → Action Pack や Action View と連携する機能をすぐに使えるようになる。
- `include ActiveModel::Serializers::JSON` で `def attributes=(hash)` を宣言しておけば、Json からモデルのインスタンスを作成できる。
```ruby
json = { name: 'Bob' }.to_json
person = Person.new
person.from_json(json) # => #<Person:0x00000100c773f0 @name="Bob">
person.name  
```
- `ActiveModel::SecurePassword` → 任意のパスワードを暗号化して安全に保存する手段を提供。
### Action View
- Action View には `テンプレート`、`パーシャル`、`レイアウト` の3つの役割がある。
#### テンプレート
- `Builder`:
  - テンプレートの拡張子が `.builder` であれば、`Builder::XmlMarkup` ライブラリの新鮮なインスタンスが使用される。( Builder テンプレートは ERB の代わりに使用できる、よりプログラミング向きな記で、特にXMLコンテンツの生成が得意)
- `JBuilder`: Builderと似ているが、XML ではなく JSON を生成する
```ruby
json.name("Alex")
json.email("alex@example.com")
```
```json
// 上のコードからの生成される Json
{
  "name": "Alex",
  "email": "alex@example.com"
}
```
- `ERB`:
  - `<% %>` タグはその中に書かれた Ruby コードを実行しますが、実行結果は出力されない。条件文やループ、ブロックなど出力の不要な行はこのタグの中に書く。
  - `<%= %> `タグでは実行結果がWebページに出力される。
  - Ruby でよく使用される print や puts のような通常の出力関数は ERB では使用できない。
  - `%>` と `-%>` の違い: `-%>`は `trim_mode` で意図しない改行が挿入されたりすることを防ぐ。
#### パーシャル (部分テンプレート)
- コードを分割するための仕組み、使い回せるようにする仕組み
- `パーシャルのファイル名`の先頭には`アンダースコア`を追加. (パーシャルファイルはフォームなど layout として使い回しができるファイルのことを言う)
- パーシャルをビューの一部に含めて出力するには、ビューで `render` メソッドを使用　`<%= render "menu" %>` 
- 他のフォルダの下にあるパーシャルを呼び出す `<%= render "shared/menu" %>`
- 通常の変数ではなく、`インスタンス変数` ( `@` を冒頭に付ける) が使われている点に注目。これは、Rails ではコントローラのインスタンス変数はすべてビューに渡されるようになっているため　(訳注: Rails はそのために背後でインスタンス変数をコントローラからビューに絶え間なくコピーし続けている)。
- 変数を渡す。`= render partial: 'shared/item_header', locals: { item: @item }`　または、`= render 'shared/item_header', { item: @item }` 他のオプションも渡したいときは、キーバリュー式で書かないといけない。
- `ActionView::Partials::PartialRenderer`は、デフォルトでテンプレートと同じ名前を持つローカル変数の中に自身のオブジェクトを持つ。つまり、次の２つのコードは等価。
- `<%= render partial: "product" %>` == `<%= render partial: "product", locals: { product: product } %>` ローカル変数の名前を変更したい場合 → `as` を使う。`<%= render partial: "product", as: "item" %>` → product partial 内部で item として使う。
- 別名のローカル変数を使用したい場合。つまり上の例で言うと、product partial 内部 で product ローカル変数以外の変数を使いたい場合。→ `object` を使う。仮に item と言うローカル変数を product として使いた場合 `<%= render partial: "product", locals: { product: @product } %>` → `<%= render partial: "product", object: @item %>` とする。このままだと @item は product として使用可能な状態なので、item として使いたいなら `as` でリネームする → `<%= render partial: "product", object: @item, as: "item" %>` これは最終的にハッシュを使ってパスする場合、`<%= render partial: "product", locals: { item: @item } %>` と等価。
- コレクションをパスする。`<%= render partial: "product", collection: @products %>`
- コレクション出力には短縮記法: `<%= render @products %>` これらは次のコードの短縮形である。
```ruby
<% @products.each do |product| %>
  <%= render partial: "product", locals: { product: product } %>
<% end %>
```
- `スペーサーテンプレート`: `:spacer_template` オプションを使用すると、主要なパーシャル同士の間を埋める第二のパーシャルを指定することができる。`<%= render partial: @products, spacer_template: "product_ruler" %>` 主要な `_product` パーシャルの合間に、スペーサーとなる `_product_ruler` パーシャルが出力されます (`_product_ruler` にはデータは渡していない)
- `パーシャルレイアウト`: `アプリケーション全体で共通のレイアウト`とは異なり、パーシャルレイアウトのファイル名冒頭には`アンダースコア`が必要
```ruby
# articles/show.html.erb
<%= render partial: 'article', layout: 'box', locals: { article: @article } %>
```
```ruby
# articles/_box.html.erb
<div class='box'>
  <%= yield %>
</div>
```
- yield を呼び出す代わりに、パーシャルレイアウト内にあるコードのブロックを出力することもできる。
```ruby
<% render(layout: 'box', locals: { article: @article }) do %>
  <div>
    <p><%= article.body %></p>
  </div>
<% end %>
```

- `link_to`: 現在と同じコントローラのアクションにリンクする場合は、`:controller` の指定は不要。コントローラを指定しなければ、デフォルトで現在のコントローラが使われる。
- `pluralize`: 数値を受け取ってそれに応じて英語の「単数形/複数形」活用を行ってくれる Rails のヘルパーメソッド。数値が 1 より大きい場合は、引数の文字列を自動的に複数形に変更する。
- `scope: :article`のようにスコープにシンボルを指定すると、フィールドが空の状態で作成される。
- `article_path(@article)ヘルパー` → article id = XX の詳細画面へのパスを作成。
#### ビューのパス
- デフォルトでは、`app/views` ディレクトリの下のみを探索。`prepend_view_path` メソッドや `append_view_path` メソッドを用いることで、パスの解決時に優先して検索される別のディレクトリを追加できる。
- コントローラのアクションの最終部分で明示的な画面出力が指示されていない場合は、コントローラが使用できるビューのパスから `アクション名.html.erb` というビューテンプレートを探し、それを使用して自動的に出力する
- 実際のレンダリングは、`ActionView::TemplateHandlers` のサブクラスで行われる
#### Helpers 
- `AssetTagHelper`: 画像・JavaScriptファイル・スタイルシート・フィードなどのアセットにビューをリンクするHTMLを生成するメソッドを提供。デフォルトでは、現在ホストされている public フォルダ内のアセットに対してリンク、アプリケーション設定 (通常はconfig/environments/production.rb) の config.action_controller.asset_host で設定されているアセット用サーバーにリンクすることもできる。たとえば、assets.example.com というアセット専用ホストを使用したいとすると、
```ruby
config.action_controller.asset_host = "assets.example.com"
image_tag("rails.png") # => <img src="http://assets.example.com/images/rails.png" />
```
- `image_path`: `image_path("edit.png") # => /assets/edit.png` `config.assets.digest` が true に設定されている場合、ファイル名にフィンガープリントが追加される。 `image_path("edit.png") # => /assets/edit-2d1a2db63fc738690021fedb5a65b68e.png`
- `image_url`: image への url を生成
- `image_tag`: img タグを生成 `image_tag("icon.png") # => <img src="/assets/icon.png" />`
- `javascript_include_tag`: js script タグを生成 `javascript_include_tag "common" # => <script src="/assets/common.js"></script>`
- `stylesheet_link_tag`: style タグ生成
- `BenchmarkHelper`: ボトルネックになりそうなコードをラップして実行時間を算出する。
- `CacheHelper`: cacheメソッドは、(アクション全体やページ全体ではなく) ビューの断片をキャッシュするメソッドです。この手法は、メニュー・ニュース記事・静的HTMLの断片などをキャッシュするのに便利
- `CaptureHelper`: テンプレートの一部を変数に保存する。保存された変数は、テンプレートやレイアウトのどんな場所でも自由に使用できる。
```ruby
# 小 file つまり、extends を記述する方
<% @greeting = capture do %>
  <p>ようこそ！日付と時刻は<%= Time.now %>です</p>
<% end %>
```
```html
<!-- extends を記述される方 layout file -->
<html>
  <head>
    <title>ようこそ！</title>
  </head>
  <body>
    <%= @greeting %>
  </body>
</html>
```
- `content_for`: 特定の id を yield する。
```html
<html>
  <head>
    <title>ようこそ！</title>
    <%= yield :special_script %>
  </head>
  <body>
    <p>ようこそ！日付と時刻は<%= Time.now %>です</p>
  </body>
</html>
```
```html
<p>これは特別なページです。</p>

<% content_for :special_script do %>
  <script>alert('Hello!')</script>
<% end %>
```
- `date_select`: select を自動生成 `<%= date_select("article", "published_on") %>`
- 日付/時刻ヘルパーの場合は、`select_date、select_time、select_datetime` が `ベアボーンヘルパー (最小限の基本機能を持つ)` で、`date_select、time_select、datetime_select` が `モデルオブジェクトヘルパー` に相当。ベアボーンペルパーを使う場合、Controller で日付を params から取り出してモデルインスタンに自分でセットする必要がある。例えば、こんな感じ。`Date.civil(params[:start_date][:year].to_i, params[:start_date][:month].to_i, params[:start_date][:day].to_i)` モデルオブジェクトヘルパー であれば、ここら辺の煩雑な作業をよろしくやってくれるため便利。params からは ハッシュとして受け取ることができる。`{'person' => {'birth_date(1i)' => '2008', 'birth_date(2i)' => '11', 'birth_date(3i)' => '22'}}` Active Record はこれらのパラメータが `birth_date 属性を構成するために使われなければならないこと`を理解し、接尾語（suffix）付きの情報を利用する。
- ベアボーンヘルパーとモデルオブジェクトヘルパーのオプションは共通。例えば、年のオプションはどちらのファミリーでもデフォルトで現在の年の前後5年が使われ、この範囲が適切でない場合は`:start_year` オプションと `:end_year` オプションを使って上書きできる、など。
- モデルオブジェクトを扱う場合は date_select を使うべ。その他の場合、たとえば`日付でフィルタするなどの検索フォーム`で使う場合は select_date を使う。
- `DebugHelper`: YAML からダンプしたオブジェクトを含む pre タグを返す。
#### FormHelper
- `form_for` および `fields_for` によって生成されるオブジェクトは、`FormBuilder` (またはそのサブクラス) のインスタンスである。
- `form_for`:
```ruby
# メモ: @person変数はコントローラ側で設定済みであるとする (@person = Person.newなど)
<%= form_for @person, url: { action: "create" } do |f| %>
  <%= f.text_field :first_name %>
  <%= f.text_field :last_name %>
  <%= submit_tag 'Create' %>
<% end %>
```
```html
<form action="/people/create" method="post">
  <input id="person_first_name" name="person[first_name]" type="text" />
  <input id="person_last_name" name="person[last_name]" type="text" />
  <input name="commit" type="submit" value="Create" />
</form>
```
- `fields_for`: form_for のような特定のモデルオブジェクトの外側にスコープを作成するが、フォームタグ自体は作成しない。このため、fields_for は同じフォームに別のモデルオブジェクトを追加するために使われる。
```ruby
<%= form_for @person, url: { action: "update" } do |person_form| %>
  First name: <%= person_form.text_field :first_name %>
  Last name : <%= person_form.text_field :last_name %>

  <%= fields_for @person.permission do |permission_fields| %>
    Admin?  : <%= permission_fields.check_box :admin %>
  <% end %>
<% end %>
```
- `file_field`: `file_field(:user, :avatar) # => <input type="file" id="user_avatar" name="user[avatar]" />`
- `collection_select`: collection から select tag と その option を作成。基本:
```ruby
<%= f.collection_select(:name, @categories, :id, :name) %>
```
```ruby
<select id="page_name" name="page[name]">
  <option value="1">Railsの基礎知識</option>
  <option value="2">Rubyの基礎知識</option>
</select>
```
- 少し応用 → categories にある関連モデルの Book を option に指定したい： name に model で指定したメソッドを使っても良い。[ref](https://railsguides.jp/action_view_overview.html#collection-select)
```ruby
collection_select(:category, :book_id, Book.all, :id, :name_with_uppercase, { prompt: true })
```
```ruby
<select name="book[category_id]">
  <option value="">Please select</option>
  <option value="1" selected="selected">Harry Potter</option>
  <option value="2">Lord of the Rings</option>
</select>
```
- 同じようなコンセプトで `collection_radio_buttons`, `collection_check_boxes`　がある。
- `option_groups_from_collection_for_select(@continents, :countries, :name, :id, :name, 3)` select の option でグループ化してあげる。この場合、 continent でグループ化している(1)。(2) でグループ化されるオプションを指定。(3) グループ名、(4) option の value, (5) option のテキスト、最後に (6)が デフォルトで selected される option のインデックス。これを select タグで囲む必要がある。
  1. `<%= f.select :post_type_id, option_groups_from_collection_for_select(@categories, :post_types, :name, :id, :name), :include_blank => "Please select..." %>` 
  2. `<%= select_tag(:city_id, options_for_select(...)) %>`
  - [ref](https://apidock.com/rails/ActionView/Helpers/FormOptionsHelper/option_groups_from_collection_for_select)
- `select`: `select("article", "person_id", Person.all.collect { |p| [ p.name, p.id ] }, { include_blank: true })`
#### FormTagHelper
- フォームタグを作成するためのメソッドを多数提供。これらのメソッドは、テンプレートに割り当てられている Active Record オブジェクトに依存しない点がFormHelperと異なる。
- `FormHelper` できることは FormTagHelper でも同じようなことは大体できる。
- `check_box_tag`: `check_box_tag 'accept' # => <input id="accept" name="accept" type="checkbox" value="1" />`
#### ローカライズされたビュー
- デフォルトでは `app/views/articles/show.html.erb`。`I18n.locale = :de` を設定すると、代りに `app/views/articles/show.de.html.erb` が出力される。
- Rails は `I18n.locale` に設定できるシンボルを制限していないので、ローカライズにかぎらず、あらゆる状況に合わせて異なるコンテンツを表示し分けるようにすることができる。
```ruby
# app/controllers/application.rb
before_action :set_expert_locale
def set_expert_locale
  I18n.locale = :expert if current_user.expert?
end
# app/views/articles/show.expert.html.erb のような特殊なビューを表示する
```
#### render, rendering
- `render "edit"` または、`render :edit` で `edit.html.erb` を表示
- `render "products/show"` または、明示的に `render template: "products/show"` とすれば、別のコントローラの配下にあるテンプレートを使用して出力できる。
- json を出力：`render json: @product`
- `コントローラ用のレイアウトを指定`: 次のように指定すると `ProductsController` からの出力で使用されるレイアウトは `app/views/layouts/inventory.html.erb` になる。
```ruby
class ProductsController < ApplicationController
  layout "inventory"
  #...
end
```
- アプリケーション全体で特定のレイアウトを使用したい → `ApplicationController` クラスで layout を宣言
```ruby
class ApplicationController < ActionController::Base
  layout "main"
  #...
end
```
- レイアウトの指定にシンボルを使う
```ruby
class ProductsController < ApplicationController
  layout :products_layout

  def show
    @product = Product.find(params[:id])
  end

  private
    def products_layout
      @current_user.special? ? "special" : "products"
    end

end
```
- `テンプレートの継承`!!!: 
```ruby
# app/controllers/application_controller
class ApplicationController < ActionController::Base
end

# app/controllers/admin_controller
class AdminController < ApplicationController
end

# app/controllers/admin/products_controller
class Admin::ProductsController < AdminController
  def index
  end
end
```
- このときのadmin/products#indexアクションの探索順序。
  1. `app/views/admin/products/`
  2. `app/views/admin/`
  3. `app/views/application/`
  - つまり、`app/views/application/` は共有パーシャルの置き場所として良い。
- redirect させたい → `redirect_to action: :index`
- redirect は ブラウザとのやりとりが1往復増えるため、処理を工夫したい → そのままリダイレクト先で表示する内容を render する。
- `<div id="content"><%= content_for?(:content) ? yield(:content) : yield %></div>` で id が存在するかどうか調べられる。この場合、content_for :content が存在すればそれを yield し、なければ、extends してるファイルの全コードを yield する。
#### form
- form_tag に class などを追加したいとき：`form_tag({controller: "people", action: "search"}, method: "get", class: "nifty_form") # => '<form accept-charset="UTF-8" action="/people/search" method="get" class="nifty_form">'`
- フォームに `<%= text_field_tag(:query) %>`というコードが含まれていたとすると、コントローラで `params[:query]` と指定すればこのフィールドの値にアクセスできる。
- `モデルオブジェクトヘルパー`: *_tag ヘルパーをモデルオブジェクトの作成/修正に用いることはもちろん可能だが、1つ1つのタグについて正しいパラメータが使われているか、入力のデフォルト値は適切に設定されているかなどをいちいちコーディングするのは何とも面倒 → モデルオブジェクトヘルパー を使用。`<%= text_field(:person, :name) %>　# => <input id="person_name" name="person[name]" type="text" value="Henry"/> を生成。` このフォームを送信すると、ユーザーが入力した値は `params[:person][:name]` に保存される。
- ヘルパーに渡すのはインスタンス変数の「名前」でないといけない。 (シンボル :person や文字列 "person" など)。`渡すのはモデルオブジェクトのインスタンスそのものではない。`!!!
- `text_field(:person, :name)` とすると何度も モデル名を呼び出さないといけない。この場合だと `:person` → `form_for` を使う。
```ruby
<%= form_for @article, url: {action: "create"}, html: {class: "nifty_form"} do |f| %>
  <%= f.text_field :title %>
  <%= f.text_area :body, size: "60x12" %>
  <%= f.submit "Create" %>
<% end %>
```
- @article は、実際に編集されるオブジェクトそのもの
- f: フォームビルダーオブジェクト
- RESTful な resource を使用している場合、form_for でリソースの取り扱いが簡単になる。レコード識別は、レコードが新しい場合には `record.new_record?` が必要とされている、などの適切な推測を行ってくれる。
```ruby
## 新しい記事の作成
# 長いバージョン
form_for(@article, url: articles_path)
# 短いバージョン(レコード識別を利用)
form_for(@article)

## 既存の記事の修正
# 長いバージョン
form_for(@article, url: article_path(@article), html: {method: "patch"})
# 短いバージョン
form_for(@article)
```
- `form_for の id と class について`： Rails はフォームの class と id を自動的に設定してくれる。この場合、記事を作成するフォームには id と、new_article という class が与えられる。もし仮に id が23の記事を編集しようとすると、`class` は `edit_article` に設定され、`id` は `edit_article_23` に設定される。
> モデルで単一テーブル継承(STI: single-table inheritance)を使っている場合、親クラスでリソースが宣言されていてもサブクラスでレコード識別を利用することはできません。その場合は、モデル名、:url、:methodを明示的に指定する必要があります。???
- `名前空間を扱う`: `form_for [:admin, @article]` ネスト指定てもコンマで宣言すれば良い。
- PATCH PUT DELETE を使う → `form_tag(search_path, method: "patch")`
> :include_blankや:promptが指定されていなくても、選択属性requiredがtrueになっていると、:include_blankは強制的にtrueに設定され、表示のsizeは1になり、multipleはtrueになりません。???
- `ファイルのアップロード`: 出力されるフォームのエンコードは 必ず 「multipart/form-data」でなければならない。form_for　ヘルパーを使えば、この点が自動的に処理される。form_tag でファイルアップロードを行なう場合は、以下の例に示したようにエンコードを明示的に指定する!!!
```ruby
<%= form_tag({action: :upload}, multipart: true) do %>
  <%= file_field_tag 'picture' %>
<% end %>

<%= form_for @person do |f| %>
  <%= f.file_field :picture %>
<% end %>
```
- ファイルがアップロードされた後の処理には [CarrierWave](https://github.com/carrierwaveuploader/carrierwave) ライブラリを使うと善い。
- `Ajaxを扱う`: Ajaxフォームのシリアライズは、ブラウザ内で実行される JavaScript によって行われる。そしてブラウザの JavaScript は(危険を避けるため)ローカルのファイルにアクセスできないようになっているので、JavaScript からはアップロードファイルを読み出せ無い。これを回避する方法として最も一般的な方法は、非表示の iframe をフォーム送信の対象として使う。

### Active Support
> Ruby on Rails アプリケーションでは、基本的にすべての Active Support を読み込みます。例外は config.active_support.bare を true に設定した場合です。このオプションを  true にすると、フレームワーク自体が必要とするまでアプリケーションは拡張機能を読み込みません。また上で解説したように、読み込まれる拡張機能はあらゆる粒度で選択されます。
- [ref](https://railsguides.jp/active_support_core_extensions.html)
- `instance_values`: クラスのインスタンス変数をハッシュにして返す。
```ruby
class C
  def initialize(x, y)
    @x, @y = x, y
  end
end
C.new(0, 1).instance_values # => {"x" => 0, "y" => 1}
```
- `instance_variable_names`: インスタンス変数名を先頭に `@` をつけて返す。
- `suppress` : 例外の発生を止める。あるブロックの実行時に例外が発生し、その例外が(`kind_of? で判定`)いずれかの引数に一致する場合、それをキャプチャして例外を発生せずに戻る。一致しない場合、例外はキャプチャしない。
```ruby
# ユーザーがロックされていればインクリメントしない
suppress(ActiveRecord::StaleObjectError) do
  current_user.increment! :visits
end
```
- `ActiveRecord::StaleObjectError`: 楽観的ロックで特定のデータが別の場所で更新されてバージョンアップされている時（`lock_version`）に吐くエラー。table の 定義に `t.integer :lock_version, default: 0` として　lock_version カラムを用意する。
```ruby
dog1 = Dog.create!(name: 'poti') # id: 1
dog1_found = Dog.find(1)
dog1_found.update(name: "korosuke")
dog1.update(name: "poti") # => ActiveRecord::StaleObjectError
```
- `in?`: あるオブジェクトが他のオブジェクトに含まれているかどうかを確認。渡された引数が `include?` が使えないオブジェクト（[],"...", Num...Num などの Iterable オブジェクト以外）使用すると　`ArgumentError 例外`
- `alias_attribute`: モデルの属性の別名 (alias) を作成。
```ruby
class User < ApplicationRecord
  # emailカラムを"login"という名前でも参照したい　=> 認証のコードがわかりやすくなる
  alias_attribute :login, :email
end
```
- `内部属性`: クラスの継承でクラス無いの同名の属性名が衝突し無いためにある。
  - `attr_internal_reader`、`attr_internal_writer`、`attr_internal_accessor`というマクロが定義されている。ライブラリは通常 `attr_accessor` の代わりに `attr_internal` を使用する。
  - `attr_*`と振る舞いは同様
  - `内部インスタンス変数`の名前にはデフォルトで冒頭に`アンダースコア`が追加される。例えば、`@_log_level` この動作は `Module.attr_internal_naming_format` で変更することもできる。`sprintf` と同様のフォーマット文字列を与え、冒頭に`@`を置き、それ以外の名前を置きたい場所に`%s`を置く。デフォルト値は `@_%s`
- `モジュール属性`: `mattr_reader`、`mattr_writer`、`mattr_accessor`という3つのマクロは、クラス用に定義される`cattr_*`マクロと同じ。`cattr_*`マクロは単なる`mattr_*`マクロの別名。
- `module_parent`メソッド: 親モジュールを定数形式で返す。
  - モジュールが無名またはトップレベルの場合 `Object` を返す。
  - `module_parents`: 全親を配列形式にして返す。
  - `module_parent_name` も同様の動きをするが、モジュールが無名またはトップレベルの場合 `nil` を返す。
```ruby
module X
  module Y
    module Z
    end
  end
end
M = X::Y::Z

X::Y::Z.module_parent # => X::Y
M.module_parent       # => X::Y
```
- `無名モジュール`: 名前が無いモジュール。`Module.new.name # => nil`
  - `anonymous?`でチェック `Module.new.anonymous? # => true`
  - 無名モジュールは、定義上必ず到達不能（unreachable）(到達不能なモジュールが必ずしも無名と言うわけでは無い)
- `メソッドの委譲 (delegate)`: `関連モデルの属性`を`自分のモデルの属性`として使えるようにするための機能。
  - 委譲するメソッドは対象クラス内で `public` でないといけない。
  - 委譲時に `NoMethodError` が発生して対象が `nil` の場合、例外が発生。`:allow_nil` オプションを使うと、例外の代りに `nil` を返す
  - `:prefix` オプションを `true` にすると、生成されたメソッドの名前にプレフィックスを追加。`delegate :street, to: :address, prefix: true` `street` ではなく`address_street` を生成
    - `プレフィックスをカスタマイズ`: `delegate :size, to: :attachment, prefix: :avatar` => `avatar_size`
  - 委譲されたメソッドはデフォルトで `public`
  - `:private` オプションでメソッドのスコープを変更
  - `User` オブジェクトにないものを `Profile` にあるものにすべて委譲したい! `delegate_missing_to` マクロを使う。オブジェクト内にある呼び出し可能なもの（`インスタンス変数`、`メソッド`、`定数`などで、スコープが public）なら何でも対象。
```ruby 
class User < ApplicationRecord
  has_one :profile
end

class User < ApplicationRecord
  has_one :profile
  def name
    profile.name # delegate
  end
end
# \\\ ↓ ///
class User < ApplicationRecord
  has_one :profile
  delegate :name, to: :profile
  # delegate :name, :age, :address, :twitter, to: :profile # => 複数移譲
end
```
- `メソッドの再定義`: 
  - `define_method` で再定義するとき、その名前が既にあると警告が出る。
  - `redefine_method` メソッドを使うと、必要に応じて既存のメソッドが削除されるから警告表示は出ない。
  - （delegateを使っているなどの理由で）メソッド自身の置き換えを定義する必要がある場合は、`silence_redefinition_of_method` を使うこともできる。
- `class_attribute` メソッドは、1つ以上の継承可能なクラスの属性を宣言
  - クラス変数を上書きするときは継承したサブクラスの値も上書きするため注意 !!!
  - これらの属性はインスタンスのレベルでアクセスまたはオーバーライドできる
    - `:instance_writer`を `false`に設定すれば、`writerインスタンスメソッド`は生成されない。`:instance_reader` も同様。これらを使用しようとすると `NoMethodError` が発生。
    - インスタンス述語が不要な場合: `instance_predicate: false`を指定
    - `x?` のように class_attribute はインスタンスの reader が返すものを「二重否定」（!!、 double-bang、二重感嘆符）するインスタンス述語も定義されている。true か false のどちらか論理値にして返す。
```ruby
class A
  class_attribute :x
end
class B < A; end
class C < B; end

A.x = :a
B.x # => :a
C.x # => :a

B.x = :b
A.x # => :a
C.x # => :b

C.x = :c
A.x # => :a
B.x # => :b
```
- cattr_reader、cattr_writer、cattr_accessor は attr_*　と似ているが、クラス用である
 - `cattr_accessor :emulate_booleans, default: true` とすると デフォルト値をセットすることができる
 - 利便性のため、このとき`インスタンスメソッド`も生成されるが、これらは実際にはクラス属性の単なるプロキシである。このため、インスタンスからクラス属性を変更することはできるが、`class_attribute` で行われるように上書きすることはできない
 - ビューで `cattr_accessor` で宣言した属性にアクセスできる
 - `:instance_reader` オプションを false に設定することで、reader インスタンスメソッドが生成されないようにできる。`:instance_writer` オプション、`:instance_accessor`オプションでも同様。
 - `:instance_accessor` を false に設定すると、モデルの属性設定時にマスアサインメントを防止するのに便利
- `subclasses`: subclasses メソッドはレシーバのサブクラスを返す
```ruby
class C; end
C.subclasses # => []
class B < C; end
C.subclasses # => [B]
class A < B; end
C.subclasses # => [B]
```
- `descendants`: descendants メソッドは、そのレシーバより`下位にあるすべてのクラス`（`直接継承しているかどうかに関わらない`と言うこと）を返す
```ruby
class C; end
C.descendants # => []
class B < C; end
C.descendants # => [B]
class A < B; end
C.descendants # => [B, A]
```
#### 安全な文字列
- 与えられた文字列に `html_safe` メソッドを適用することで、安全な文字列を得ることができる
  - ここで注意しなければならないのは、`html_safe` メソッドそれ自体は何らエスケープを行なっていないということ。安全であるとマーキングしているだけで、開発者が意図的に安全であることを認識している時に使用される。
  - 安全であると宣言された文字列に対し、安全でない文字列を `concat / << + `で破壊的に追加すると、結果は安全な文字列になるため、安全でない引数は追加時にエスケープされる
  - 現在の Rails のビューでは、安全でない値は自動的にエスケープされる
  - ビューでエスケープさせたく無い場合は、raw ヘルパーを使う。または `<%==` (raw ヘルパーは、内部で html_safe を呼び出している)
  - downcase、gsub、strip、chomp、underscore などの変換メソッドは文字列を変換するため、危険な文字列へ変換しないように注意する。また、`gsub!` のような破壊的な変換を行なうメソッドを使うと、レシーバ自体が安全でなくなってしまう。`こうしたメソッドを実行すると、実際に変換が行われたかどうかにかかわらず、安全を表すビットは常にオフになる` !!!
  - `変換と強制`: 
    - 安全な文字列に対して `to_s` を実行した場合は、安全な文字列が返される。
    - 安全な文字列に対して `to_str` による強制的な変換を実行した場合には安全でない文字列が返される。
  - `コピー`:
    - 安全な文字列に対して `dup` または `clone` を実行した場合は、安全な文字列が生成される。
```ruby
s = "".html_safe
s.html_safe? # => true

s = "<script>...</script>".html_safe
s.html_safe? # => true
s            # => "<script>...</script>"

"".html_safe + "<" # => "&lt;"

<%= raw @cms.current_template %> <%# @cms.current_templateをそのまま挿入 %>
<%== @cms.current_template %> <%# @cms.current_templateをそのまま挿入 %>
```
- `squish メソッド`: 冒頭と末尾のホワイトスペースを除去し、連続したホワイトスペースを1つに減らす
- `truncateメソッド`: 指定された length にまで長さを切り詰めたレシーバのコピーを返す
  - `:omission オプション`: 省略文字 `(...)` をカスタマイズ
  - `:separator`: 自然な区切り位置で切り詰めることができる（単語が切れない）正規表現も使える。`"Oh dear! Oh dear! I shall be late!".truncate(18, separator: /\s/)`
- `inquiry`: 文字列を `StringInquirer オブジェクト`に変換。このオブジェクトを使うと、等しいかどうかをよりスマートにチェックできる
```ruby
"production".inquiry.production? # => true
"active".inquiry.inactive?       # => false
```
- `start_with?`と`end_with?`もある。
- `at(position)`: 対象となる文字列のうち、`position`で指定された位置にある文字を返す. `"hello".at(0) # => "h"` `"hello".at(0..2) # => "hel"`
- `from(position)`: position で指定された一から始まる部分文字列を返す `"hello".from(0) # => "hello"`
- `to(position)`: positionで 指定された位置を終端とする部分文字列を返す `"hello".to(0) # => "h"`
- ActiveSupportのString拡張(活用形)まとめ [参考](https://qiita.com/hana-da/items/ec9ac3e1c8803f5fa1fc)
- `"SSLError".underscore.camelize` は、"SslError" となるため元に戻らない。こう言うときは、`acronym` を使う。
  - `acronym` をやっておくと humanize でも上手く調整できる. `'ssl_error'.humanize # => "SSL error"`
```ruby
ActiveSupport::Inflector.inflections do |inflect|
  inflect.acronym 'SSL'
end
"SSLError".underscore.camelize # => "SSLError"
```
- `underscore`: `::`は`\`へ変換される。`"Backoffice::Session".underscore` → `"backoffice/session"`
  - 小文字で始まる文字列も扱える: `"visualEffect".underscore` # => `"visual_effect"`
- `tableize` ⇄ `classify`(モデル名を取得できる。常に単数系)
  - フルパスの (qualified) テーブル名も扱える: `"highrise_production.companies".classify # => "Company"`
  - `classify` が返すクラス名は文字列であることにご注意。得られた文字列に対して `constantize` を実行することで本当のクラスオブジェクトを得られる。
- date conversion: 
  - `"2010-07-27".to_date`
  - `1.month.from_now`
  - `(4.months + 5.weeks).from_now`
- format:
  - `1235551234.to_s(:phone, area_code: true) # => (123) 555-1234`
  - `1235551234.to_s(:phone, delimiter: " ") # => 123 555 1234`
  - `12345678.to_s(:delimited) # => 12,345,678`
  - `111.2345.to_s(:rounded, precision: 2) # => 111.23`
  - `1.ordinal # => "st"`. `ordinalize` もある
- `enumerable`
  - `(1..5).sum {|n| n * 2 } # => 30`
  - `[2, 4, 6, 8, 10].sum    # => 30`
- `fetch`: キーが存在するかどうか判別する。
```ruby
h = {one: nil}
p h[:one],h[:two]                        #=> nil,nil これではキーが存在するのか判別できない。
p h.fetch(:one)                          #=> nil
p h.fetch(:two)                          # エラー key not found (KeyError)
```
- `dig`: hash と array に対し、value に簡単に取得する
```ruby
h = { foo: {bar: {baz: 1}}}

h.dig(:foo, :bar, :baz)      # => 1
h.dig(:foo, :zot, :xyz)      # => nil

g = { foo: [10, 11, 12] }
g.dig(:foo, 1)  
```
- `select, keep_if` は `filter` のような動きと同じ [ref](https://qiita.com/jnchito/items/02ba8aad634a6bd8a2f6)
- `assoc`: Returns the first contained array that matches (that is, the first associated array), or nil if no match is found
  - `rassoc` は value を元に探す（Returns the first contained array）
```ruby
s1 = [ "colors", "red", "blue", "green" ]
s2 = [ "letters", "a", "b", "c" ]
s3 = "foo"
a  = [ s1, s2, s3 ]
a.assoc("letters")  #=> [ "letters", "a", "b", "c" ] # 初めの要素をキーとして検索して、マッチした配列全てを返す
a.assoc("foo")      #=> nil
```
- `compact`: `[ "a", nil, "b", nil, "c", nil ].compact #=> [ "a", "b", "c" ]`
- `&:メソッド名` はブロック変数渡しより若干高速 [ref](https://github.com/rails/rails/pull/32337)
- `merge` じゃなく `[]=` を使う
```ruby
hash = {key: 'value'}
hash[:new_ley] = 'new value'
```
- `index_by メソッド`: 何らかのキーによってインデックス化された enumerable の要素を持つハッシュを生成
- `index_withメソッド`: enumerable の要素をキーとして持つハッシュを生成
- `User.exists?(email: params[:email])`: このような `シンタックスシュガー`は、多数の引数が順序に依存することを避け、名前付きパラメータをエミュレートするインターフェイスを提供するために Rails で多用されています。特に、末尾にオプションのハッシュを置くというのは定番中の定番. しかし、あるメソッドが受け取る引数の数が固定されておらず、メソッド宣言で`*`が使われていると、そのような波かっこなしの`オプションハッシュ`は引数の配列の末尾の要素になってしまい、ハッシュとして認識されなくなってしまう。このような場合、`extract_options!`メソッドは、配列の最後の項目の型をチェックする。それがハッシュの場合、そのハッシュを取り出して返し、それ以外の場合は空のハッシュを返す。
- `to_formatted_s` メソッドはデフォルトでは`to_s`と同様に振る舞い
  - :db シンボルを引数に渡すと Active Record オブジェクトのコレクションに対して id に応答する項目を返す。
```ruby
user = User.find(1)
[user].to_formatted_s(:db) # => 1
```
- `Array.wrap`: `to_ary` から返された値が nil でも Array オブジェクトでもない場合、`Kernel#Array`は例外を発生。`Array.wrap`は例外を発生せずに単にその値を返す。([])
```ruby
Array.wrap(foo: :bar) # => [{:foo=>:bar}]
Array(foo: :bar)      # => [[:foo, :bar]]
[*{:foo=>:bar}]       # => [[:foo, :bar]]
```
- `in_groups_of`: `(1..7).to_a.in_groups_of(3, 0) # => [[1, 2, 3], [4, 5, 6], [7, 0, 0]]`
- `in_groups`: `(1..7).to_a.in_groups(3, 0)       # => [[1, 2, 3], [4, 5, 0], [6, 7, 0]]`
  - `(1..7).to_a.in_groups(3, false)              # => [[1, 2, 3], [4, 5], [6, 7]]`
- `split`: 指定のセパレータで配列を分割 `(-5..5).to_a.split { |i| i.multiple_of?(4) } # => [[-5], [-3, -2, -1], [1, 2, 3], [5]]` 4 で split するため, 4 はメンバーから消える。4 が続くときは からの配列 `[]` が間に入る。

- merge: `{a: 1, b: 1}.merge(a: 0, c: 2)` merge　でキーが衝突した場合、`引数のハッシュのキーが優先される`。（= レシーバは上書きされる）
- deep_merge: レシーバと引数の両方に同じキーが出現し、さらに`どちらも値がハッシュである場合`(どちらかが hash じゃ無い場合は レシーバは上書きされる)に、その下位のハッシュをマージしたものが、最終的なハッシュの値として使われる。`{a: {b: 1}}.deep_merge(a: {c: 2})　# => {:a=>{:b=>1, :c=>2}}` どちらも値がハッシュである限り deep_merge は再起的に merge する。`{a: {b: {e: 'f'}}}.deep_merge(a: {b: {c: 'd'}}) # => {:a=>{:b=>{:e=>"f", :c=>"d"}}}`
- `except`: 引数で指定されたキーがあればレシーバのハッシュから取り除く `{a: 1, b: 2}.except(:a) # => {:b=>2}`
- `with_indifferent_access`: ハッシュに文字列で`も`アクセス
```ruby
test = {:key=>"value"}
test['key'] # => nil
test.with_indifferent_access['key'] # => value
test.with_indifferent_access.except('key') # => {}
```
- `stringify_keys`: `{nil => nil, 1 => 1, a: :a}.stringify_keys`
  - キーが重複している場合、最後に挿入された値
  - `deep_stringify_keys`: 再起的に stringify_keys を行う `{nil => nil, 1 => 1, nested: {a: 3, 5 => 5}}.deep_stringify_keys`
- `symbolize_keys`: レシーバのハッシュキーをシンボルに変換したハッシュを返す(別名 `to_options`)
  - 数字や nil はシンボルに変換され無い
  - `to_sym`: レシーバをシンボル化する `'hello'.to_sym # => "hello"`
  - `deep_symbolize_keys`: 再起的に シンボル化する
- `to_s`:
```ruby
(Date.today..Date.tomorrow).to_s
# => "2009-10-25..2009-10-26"
(Date.today..Date.tomorrow).to_s(:db) # db 形式に変換
# => "BETWEEN '2009-10-25' AND '2009-10-26'"
```
- `Range#===メソッド、Range#include?メソッド、Range#cover?メソッド`: 与えられたインスタンスの範囲内に値が収まっているかどうかをチェックする
```ruby
(1..10) === (3..7)  # => true
(1..10) === (0..7)  # => false

(1..10).include?(3..7)  # => true
(1..10).include?(0..7)  # => false

(1..10).cover?(3..7)  # => true
(1..10).cover?(0..7)  # => false
```
- `Range#overlaps?`: 与えられた2つの範囲に（空白でない）重なりがあるかどうかをチェック。 日付の差などに便利。
- laravel の carbon のようなサービスは rails だと active support でデフォルトで用意している。
 - 時を先に進める：`date.advane(yearhs:1, weeks: 2)`
 - 時を遡る：`date.advance(months: -2, days: -2)`
 - `ago`: 秒数で指定した分だけ遡る
 - `since`: 秒数だけ先にすすむ
 - `Marshal`: Ruby オブジェクトをファイル(または文字列)に書き出したり、読み戻したりする機能を提供するモジュール。大部分のクラスのインスタンスを書き出す事ができますが、書き出しの不可能なクラスも存在します(Marshal.#dump を参照)。ここで「`マーシャルデータ`」と言う用語は、`Marshal.#dump` が出力する文字列を指す。Python の pickle のようなモジュール。（pandas.to_pickle）
 - `NameError の拡張`: `missing_name?`は、引数として渡された名前が原因で例外が発生するかどうかをテストするために使われる
 - `LoadEror の拡張`: `is_missing?`は、パス名を引数に取り、特定のファイルが原因で例外が発生するかどうかをテストするために使われる
 ```ruby
 def default_helper_module!
  module_name = name.sub(/Controller$/, '')
  module_path = module_name.underscore
  helper module_path
rescue LoadError => e
  raise e unless e.is_missing? "helpers/#{module_path}_helper"
rescue NameError => e
  raise e unless e.missing_name? "#{module_name}Helper"
end
 ```
- `helper` class method: add Additional helpers to class(Controller) and let it use in erb. [ref](https://api.rubyonrails.org/classes/ActionController/Helpers.html)
```ruby
module FormattedTimeHelper
  def format_time(time, format=:long, blank_message="&nbsp;")
    time.blank? ? blank_message : time.to_s(format)
  end
end
class EventsController < ActionController::Base
  helper FormattedTimeHelper
  def index
    @events = Event.all
  end
end
<% @events.each do |event| -%>
  <p>
    <%= format_time(event.time, :short, "N/A") %> | <%= event.name %>
  </p>
<% end -%>
```
### Storage
- `has_one_attached :avatar`だけで User record に画像を関連づけできる。
- 既存ユーザーに attach: `Current.user.avatar.attach(params[:avatar])`
- attach 済みかどうか検証: `Current.user.avatar.attached?`
- `has_many_attached`で１対多の関係を設定。
- `File/IO Objectsをアタッチ`: `オープン IO オブジェクトとファイル名を1つ以上含むハッシュを渡す` → `@message.image.attach(io: File.open('/path/to/file'), filename: 'file.pdf')`
  - 可能であれば、`content_type:`も指定する。Active Storage は、渡されたデータからファイルの `content_type` の判定を試みるが、判定できない場合は content_type にフォールバックする。
- `ファイルを削除`: `user.avatar.purge`
- エンドポイントを base url にしたリンクを生成: `url_for(user.avatar)`
- ダウンロードリンクを作成: `rails_blob_path(user.avatar, disposition: "attachment")`
- コントローラやビューのコンテキストの外(バックグラウンドジョブやcronジョブなど)からリンクを作成したい場合: `Rails.application.routes.url_helpers.rails_blob_path(user.avatar, only_path: true)`
- プレビュー画像の抽出にはサードパーティのアプリケーションが必要（動画の場合は `ffmpeg` 、PDF の場合は `mutool`）
```ruby
<ul>
  <% @message.files.each do |file| %>
    <li>
      <%= image_tag file.preview(resize: "100x100>") %>
    </li>
  <% end %>
</ul>
```
- Active Storage は、付属の JavaScript ライブラリを用いて、クライアントからクラウドへのダイレクトアップロードをサポートしている。
- `システムテスト中に保存したファイルを破棄する`: システムテストでは、トランザクションをロールバックすることでテストデータをクリーンアップするが、destroy はオブジェクトに対して呼び出されないため、添付ファイルはそのままでは決してクリーンアップされ無い。 添付ファイルを破棄したい場合は、`after_teardown`コールバックで行える。
- `メモリーリークのデバッグ`:
  - `Valgrind` はアプリケーションであり、Cコードベースのメモリーリークや競合状態の検出

### Command Line Tool
- `rails server`:
  - `-e` オプションでサーバーの環境を変更。デフォルトは `development` (開発) 環境
  - `-b` オプション: Rails を特定の IP にバインド。デフォルトは `localhost`
  - `-d` オプションを使うと、デーモンとしてサーバーを起動

> 単体テスト（unit test）について説明します。単体テストとは、コードをテストしてアサーション（コードが期待どおりに動作するかどうかを確認すること）を行うコードです。単体テストでは、モデルのメソッドといったコードの一部分を取り出して、入力と出力をテストします。単体テストはあなたにとって友人と同じぐらい大事なものです。単体テストを書けば人生が幸福で満たされるという事実に早いうちから気づいた人は、間違いなく他人より先に幸せになれるでしょう。単体テストについて詳しくは、the testing guide を参照してください。

- `rails console`:
  - `rails console --sandbox`: `--sandbox`を付ければ db のデータを変更しても exit 時に rollback する。
  - `appオブジェクトとhelperオブジェクト`: 
    - `app.root_path`
    - `helper.time_ago_in_words 30.days.ago`
  - `rails dbconsole`(rails db): app で使用している db へ直接接続
  - `rails runner`: 非対話的に Rails の文脈で Ruby のコードを実行 `rails runner "Model.long_running_method"`
    - ファイル内の Ruby コードを runner で実行することもでき `rails runner lib/code_to_be_run.rb`
- `rails destroy`: generate のちょうど反対
- `rails assets`: precompile, clean, clobber などのオプションがある。
- `rails notes`: コードのコメントから `FIXME`、`OPTIMIZE`、`TODO`で始まる行を探し出して表示。 
  - `[FIXME]`のように`[`から始まるものはヒットし無い
  - 検索対象となるファイルの拡張子は `.builder、.rb、.rake、.yml、.yaml、.ruby、.css、.js、.erb`
  - デフォルトのアノテーション以外に独自のアノテーションも利用できる
    - `--annotations` 引数を用いて、特定のアノテーションを渡す
    - アノテーションは`大文字小文字を区別`する点に注意
  - デフォルトディレクトリを追加: `config.annotations.register_directories`
  - デフォルトファイル拡張子を追加: `config.annotations.register_extensions`
### アセットパイプライン (Sprockets がファイルをまとめるまでの工程)
- JavaScript や CSS のアセットを最小化 (minify: スペースや改行を詰めるなど) または圧縮して連結するためのフレームワーク
- `app/assets/`:  css, js フォルダを作成して管理
- `lib/assets/`: 1つのアプリケーションの範疇に収まらないライブラリのコードや、複数のアプリケーションで共有されるライブラリのコードを置く
- `vendor/assets`: JavaScript プラグインや CSS フレームワークなど、外部の団体などによって所有されているアセットの置き場所
- `Rails.application.config.assets.paths`: assets の path を探索
    - 追加：`Rails.application.config.assets.paths << Rails.root.join("lib", "videoplayer", "flash")`
- assets のリンクするコードをかく
  - Rails から同梱されるようになった `turbolinks gem` を使用している場合、'data-turbolinks-track' オプションが利用できる。これはアセットが更新されてページに読み込まれたかどうかを turbolinks がチェックする。
```ruby
<%= stylesheet_link_tag "application", media: "all" %>
<%= javascript_include_tag "application" %>
# ↓
<%= stylesheet_link_tag "application", media: "all", "data-turbolinks-track" => "reload" %>
<%= javascript_include_tag "application", "data-turbolinks-track" => "reload" %>
```
- css アセットファイルに erb という拡張子を追加すると (`application.css.erb`など)、CSS ルール内で asset_path などのヘルパーが使用できるようになる
```ruby
.class { background-image: url(<%= asset_path 'image.png' %>) }
```
- `asset-url("rails.png")`は `url(/assets/rails.png)`に変換される
- `asset-path("rails.png")`は `"/assets/rails.png"`に変換される
- `ダイジェストをオフ`: `config.assets.digest = false`

- フィンガープリントと注意点:
> アセットファイル名で使用されるフィンガープリントは、アセットファイルの内容に応じて変わります。アセットファイルの内容が少しでも変わると、アセットファイル名も必ずそれに応じて変わります (訳注: MD5の性質により、異なるファイルからたまたま同じフィンガープリントが生成されることはほぼありません)。変更されていないファイルやめったに変更されないファイルがある場合、フィンガープリントも変化しないので、ファイルの内容が完全に同一であることが容易に確認できます。これはサーバーやデプロイ日が異なっていても有効です。アセットファイル名は内容が変わると必ず変化するので、CDN、ISP、ネットワーク機器、Webブラウザなどあらゆる場面で有効なキャッシュをHTTPヘッダに設定することができます。ファイルの内容が更新されると、フィンガープリントも更新されます。これにより、リモートクライアントは (訳注: 既存のキャッシュを使用せずに) コンテンツの新しいコピーをサーバーにリクエストします。この手法を一般に キャッシュ破棄 (cache busting) と呼びます。Sprocketsがフィンガープリントを使用する際には、ファイルの内容をハッシュ化したものをファイル名 (通常は末尾) に追加します。たとえば、global.cssというCSSファイル名は以下のようになります。
`global-908e25f4bf641868d8683022a5b62f54.css` `global-＜Digest値＞.css`

- 基本的に Webpack をラップした Webpacker を使うようにする。
- エントリーファイルは app/javascript/packs におく
  - Webpack によりそれぞれ 1 つのファイルにバンドルされる
-　完全に Webpacker に移行できる場合は以下の gem は Webpack により置き換わるので不要となる。
  - `closure-compiler`
  - `uglifier`
  - `yui-compressor`
  - `sass-rails`
- バンドルされたファイルと app/javascript/images 等に配置されたファイルは静的ファイルとしてブラウザからアクセスできるパスに配置される
  - development 環境で `rails s` した場合は必要に応じてバンドル処理が実行される
  - 明示的に `rails webpacker:compile` を実行(`rails assets:precompile` を実行すると続いて実行される)
  - /packs/application-＜Digest値＞.js 等でアクセスできる
- `javascripts/packs/application.js` に書かれた require はファイル内容がそのまま展開されずに Webpack によりバンドルされるため var が競合しない
- HTML タグを埋め込むための`ヘルパーメソッド`がある
  - JavaScript 用の `<%= javascript_pack_tag 'MODULE_NAME' %>` を使うと `<script /> タグ`が生成される
  - CSS 用の `<%= stylesheet_pack_tag 'MODULE_NAME' %>` を使うと `<link /> タグ`が生成される
- バンドルしたファイルへのパスはヘルパーメソッドがある
  - `asset_pack_path(＜アセットファイル名＞)` により取得できる
- [ref](https://qiita.com/tatsurou313/items/645cbf0a3af4c673b5df)
- `Webpacker で取り扱えるファイルの拡張子を増やす` Webpack のローダを設定することにより `.js.erb` のような ERB テンプレートや、`.vue` のような Vue.js ファイルを読み込むこともできる。ERB テンプレートを読み込めるようにする場合は `rails webpacker:install:erb` を実行すれば Webpack の loader がインストールされ、Webpack の設定が更新される。[ref](https://github.com/rails/webpacker#erb)

#### Autoload
- 通常の Rails アプリケーションで `require` 呼び出しを行うのは、`lib`ディレクトリにあるものや、`Ruby`標準ライブラリ、`Ruby gem`である。
- `Zeitwerkモードを有効化`:  Rails 6 以上ではデフォルト
  - `zeitwerk モード の Rails`は、内部で自動読み込み、再読み込み、eager loading に Zeitwerk を用いる
  - Rails は、`プロジェクトを管理する専用の Zeitwerk インスタンス`のインスタンス化や設定を行う
    - アプリを管理するZeitwerkのインスタンス: `Rails.autoloaders.main` で取得
    - zeitwerkモードが有効かどうか: `Rails.autoloaders.zeitwerk_enabled?`
```ruby
# config/application.rb
config.load_defaults "6.0" # CRubyでzeitwerkモードが有効になる
```
- Rails アプリケーションで使うファイル名は、そこで定義されている定数名と一致しなければならない
  - たとえば、`app/helpers/users_helper.rb`ファイルでは`UsersHelper`を定義すべき
  - `app/controllers/admin/payments_controller.rb`では`Admin::PaymentsController`を定義すべき
  - Railsは、ファイル名を`String#camelize`で活用するよう`Zeitwerk`を設定
    - たとえば、`app/controllers/users_controller.rb`は、以下のために`UsersController`という`定数`を定義 `"users_controller".camelize # => UsersController`
- `自動読み込みパス（autoload path）`: その中身が自動読み込みの対象となるアプリケーションディレクトリを指す（app/modelsなど）
  - これらのディレクトリはルート名前空間 Object を表す
  - Zeitwerk のドキュメントでは `自動読み込みのパス` を`ルートディレクトリ`と呼んでいる
  - `app/helpers/users_helper.rb`に`UsersHelper`が実装されていれば、そのモジュールは以下のように自動読み込み可能になる。したがって require 呼び出しは不要
  - `自動読み込みパス`は、`app`の下のあらゆる`カスタムディレクトリ`を自動的に扱う
    - たとえば、アプリケーションに`app/presenters`や`app/services`があれば、自動読み込みパスに追加される
- `再読み込み`: Rails アプリケーションのファイルが変更されると、クラスやモジュールを自動的に再読み込みする
  - 正確に言うと、Web サーバーが実行中の状態でアプリケーションのファイルが変更されると、Rails は次のリクエストが処理される直前にすべての定数をアンロードする。これによって、アプリケーションでリクエスト継続中に使われるクラスやモジュールが自動読み込みされるようになり、続いてファイルシステム上の現在の実装が反映される。
  - Rails コンソールでは、 `config.cache_classes`の値にかかわらずファイルウォッチャーは動作し無い。通常、コンソールセッションの最中に再読み込みが行われると混乱を招く可能性があるので、アプリケーションのクラスやモジュールは変更されない一貫した状態で個別のリクエストを提供することが一般に望まれる。ただし、`reload!`を実行することで強制的に再読み込みできる。
- `トラブルシューティング`: 
  - `config/application.rb` に `Rails.autoloaders.log!` を追加すると、標準出力にトレースが出力される。
  - ファイルに出力したい場合は、`Rails.autoloaders.logger = Logger.new("#{Rails.root}/log/autoloading.log")` とする。Rails ロガーは`config/application.rb`には設定されて無いが、`イニシャライザ`で設定されている（`config/initializers/log_autoloaders.rb`）
- `STI(単一テーブル継承)`
  - 単一テーブル継承機能は、`lazy loading`との相性があまりよく無い。一般に単一テーブル継承の API が正しく動作するには、`STI 階層`を正しく列挙できる必要があるため。`lazy loading`では、クラスが参照されるまでクラス読み込みは遅延される → まだ参照されていないものは列挙できない。→ アプリケーションは STI階層 を読み込みモードにかかわらず`eager load`する必要がある。
  - [STI（単一テーブル継承）とメタプログラミングでDRY](https://qiita.com/kidach1/items/789c2e7aebbcfbd2583e#cntroller%E3%81%AE%E5%AE%9F%E8%A3%85%E3%81%A8%E3%83%A1%E3%82%BF%E3%83%97%E3%83%AD%E3%82%B0%E3%83%A9%E3%83%9F%E3%83%B3%E3%82%B0)
  - [send メソッドのいろいろな書き方](https://qiita.com/ngron/items/05d3a9624c2c3ec5dbb6)
  - `instance_variable_set`, `instance_variable_get`: インスタンスにインスタンス変数をセット、ゲット [ref](https://docs.ruby-lang.org/ja/latest/method/Object/i/instance_variable_set.html)
  - `const_get`: クラスに継承または宣言された定数を参照 [ref](https://docs.ruby-lang.org/ja/latest/method/Module/i/const_get.html)
```ruby
module Bar
  BAR = 1
end
class Object
  include Bar
end
p Object.const_get(:BAR)   # => 1 # Object では include されたモジュールに定義された定数を見付ける
# 定義されていない定数
p Baz.const_get(:NOT_DEFINED) #=> raise NameError
# 第二引数に false を指定すると自分自身に定義された定数から探す !!!
p Baz.const_get(:BAR, false) #=> raise NameError
# 完全修飾名を指定すると include や自分自身へ定義されていない場合でも参照できる
p Class.const_get("Bar::BAR") # => 1
```
- Rails で `self.class.const_get("User")` として、定数名を渡すと`クラスオブジェクト`を呼び出すことができる
  - `self.class.const_get("User").new` new で新しいレコードを作成
  - 文字列に対して、`constantize` を実行することでクラスオブジェクトを得られる (`ref → L:1457`)

### Cache: how to cache view template and records for better performance
- キャッシュの手法を3種類:
  - `ページキャッシュ`:
    - apache や nginx などの `webサーバー`によって生成されるページへのリクエストを（Rails スタック全体を経由せずに）キャッシュするメカニズム
    - ページキャッシュはきわめて高速だが、常に有効とは限らない（たとえば、認証にはページキャッシュは適用されない）
    - web サーバーは`ファイルシステム`から直接ファイルを読み出して利用するため、`キャッシュの有効期限の実装も必要`
  - `アクションキャッシュ`:
    - 1つ目の`ページキャッシュ`は、`before_filter`のあるアクション（`認証の必要なページ`など）には適用できない場合に使われる。
    - web サーバーへのリクエストが `Rails スタック`にヒットしたときに、`before_filter`を実行してからキャッシュを返す点が異なる。
    - キャッシュの恩恵を受けながら、認証などの制限をかけられる
  - `フラグメントキャッシュ`: 本体に組み込まれているためデフォルトで利用できる。（production 環境でのみ有効）
  - ローカルでキャッシュを使いたい場合は、対応する`config/environments/*.rb`ファイルで`config.action_controller.perform_caching`を`true`に設定
    - `config.action_controller.perform_caching = true`
    - ページ内の異なる部品について、キャッシュや期限切れを個別に設定したい場合に使う
    - `views/products/1-201505056193031061005000/bea67108094918eeba42cd4a6e786901`
      - **キーの中間**にある長い数字は、`product_id` と、`product レコードの updated_at 属性のタイムスタンプ値`
        - タイムスタンプ値は、古いデータを返さないようにするために使われる。`updated_at 値`が更新されると新しいキーが生成され、そのキーで新しいキャッシュを保存する。
        - 古いキーで保存された古いキャッシュは二度と利用されなくなる → この手法は「`キーベースの有効期限`」と呼ばれる
      - ビューのフラグメントが変更された場合（ビューの HTML が変更された場合など）にも期限が切れる
      - `テンプレートツリーダイジェスト`: **キーの後半**にある文字列
    - `ロシアンドールキャッシュ`: `フラグメントキャッシュ`内で、さらに`フラグメントをキャッシュ`
      - たとえば内側のフラグメントで製品（`product`）が1件だけ更新された場合に、内側の他のフラグメントを捨てずに再利用し、外側のフラグメントは通常どおり再生成できる
      - 関連モデルが更新されても ファイルが直接依存しているレコードではないため、update_at timestamp はそのまま。つまりアプリケーションは古いデータを返す。これを修正したい場合はk関連モデルが更新された時に、touch をしてモデル同士を結びづける。`belongs_to :product, touch: true`
- `コレクションキャッシュ`: render ヘルパーでは、コレクションを指定して個別のテンプレートをレンダリングするときにもキャッシュを利用できる。
  - 前回までにレンダリングされた全`キャッシュテンプレート`を一括で読み出し: `<%= render partial: 'products/product', collection: @products, cached: true %>` → 劇的に速度が向上
### Instrumentation API
- Active Supportに 含まれている Instrumentation API は、Ruby コードで発生する特定の動作の計測に利用できる
- この API をアプリケーションで実装すると、アプリケーション（または Ruby コード片）内部でイベントが発生したときに通知を受け取れるよう他の開発者が設定できる
- たとえば Active Record には、データベースへの SQL クエリが発行されるたびに呼び出されるフックが用意されている。このフックを`サブスクライブ（購読）`すると、特定のアクションでのクエリ実行数を追跡できる。
- [オブジェクト同士の繋り](https://gist.github.com/eiel/7177959):
  - 通知はオブジェクト同士がメッセージのやりとりをするために使う
  - 繋りをすごく緩くしたい時に便利な機能
### Rails を API として使う
- `API 専用 Rails アプリケーションの生成`: `rails new my_api --api`
  - 利用するミドルウェアを`通常よりも絞り込んで`アプリケーションを起動するよう設定。特に、ブラウザ向けアプリケーションで有用なミドルウェア（cookiesのサポートなど）を一切利用しない
    - `rails middleware`：アプリケーションの全ミドルウェアを表示
  - `ApplicationController`を、通常の`ActionController::Base`の代わりに`ActionController::API`から継承
  - ミドルウェアと同様、`Action Controller`モジュールのうち、ブラウザ向けアプリケーションでしか使われないモジュールをすべて除外します。
  - `ビュー、ヘルパー、アセット`を生成しないようジェネレーターを設定
- `既存アプリケーションを API 専用に変更`: 
  - `config/application.rbのApplication`クラス定義の冒頭に、`config.api_only = true` を追加
- エラーの表示方法を指定:
  - development モードでのエラー発生時にレスポンスで使う形式を設定するには、`config/environments/development.rb`ファイルで`config.debug_exception_response_format`を設定
    - `config.api_only`を`true`に設定 → `config.debug_exception_response_format` はデフォルトで `:api`
    - `:default`: HTML ページにデバッグ情報を表示 (`config.debug_exception_response_format = :default`)
    - `:api`: レスポンスの形式を保ったままデバッグ情報を表示 (`config.debug_exception_response_format = :api`)
- `キャッシュミドルウェアを使う`: 
  - `stale?`呼び出しは、リクエストにある`If-Modified-Since`ヘッダと`@post.updated_at`を比較。ヘッダが最終更新時より新しい場合、`「304 Not Modified」`を返すか、レスポンスをレンダリングして`Last-Modified`ヘッダをそこに表示する。
  - `クロスクライアントキャッシュ`: キャッシュミドルウェアがあると`クライアント間`でこのキャッシュを共有できるようになる。stale?の呼び出し時に option の `public: true` を追加することで有効にできる。
```ruby
def show
  @post = Post.find(params[:id])
  if stale?(last_modified: @post.updated_at)
    render json: @post
  end
end
```
- `X-Sendfile`: NGINX のドキュメントによると「認証、ロギングなどをバックエンドで処理した後、内部リダイレクトされた場所からエンドユーザにコンテンツを配信するように`Webサーバが`処理することで、`バックエンドを解放`して他の要求を処理させる仕組み」である。Web　サーバにコンテンツ配信をさせ、`バックエンドのスループットを向上させる`ための機能、ということ
 - 不特定多数に公開しないコンテンツなので `X-Sendfile` を使う（誰にでも公開できるファイルならリダイレクトでいい）[ref](https://nacl-ltd.github.io/2017/01/07/aws-s3-file-download.html#:~:text=X%2DSendfile%E3%81%A8%E3%81%AF%E3%80%81NGINX,%E3%81%95%E3%81%9B%E3%82%8B%E4%BB%95%E7%B5%84%E3%81%BF%E3%80%8D%E3%81%A0%E3%81%9D%E3%81%86%E3%81%A7%E3%81%99%E3%80%82)
 - 定番のサーバーでファイル送信アクセラレーションを有効にするには、ヘッダに次のような値を設定
 ```ruby
 # Apacheやlighttpd
config.action_dispatch.x_sendfile_header = "X-Sendfile"
# Nginx
config.action_dispatch.x_sendfile_header = "X-Accel-Redirect"
 ```
- `ActionDispatch::Request#params`は、クライアントからのパラメータを `JSON 形式`で受け取り、コントローラ内部の `params`でアクセスできるようにする。
  - JSON エンコード化したパラメータをクライアントから送信し、`Content-Type`に `application/json`を指定
- [APIクライアントになる場合に便利なミドルウェア](https://railsguides.jp/api_app.html#%E3%81%9D%E3%81%AE%E4%BB%96%E3%81%AE%E3%83%9F%E3%83%89%E3%83%AB%E3%82%A6%E3%82%A7%E3%82%A2)
- [`rescue_from` による例外処理：アプリ固有のエラーハンドリングとエラーページ表示](https://qiita.com/E-46/items/03c30c2d37aae3756ecc)