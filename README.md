# terraform-apigw-ex4-openapi

TerraformでAWS Lambda (Python) & API Gateway (powered by OpenAPI) のサンプル。

AWS SAMのテンプレート"hello world"との比較用。同等の使いごこちを目指す(debugはないけど)。
わざと1個のhclにしてある。モジュールにできるところいっぱいあるけど理解優先。
またbackendもlocalのまま。

requirements.txtをサポートする。


# いるもの

- Terraform 1.2以上
- Python 3.9と3.9のpip (バージョンはvariableで変更可能)
- Python 3.9が `$ python3.9` で実行できること。

あとAWSアカウントは、環境変数やdefaultとして設定されてるものをそのまま使います。


# デプロイ

```bash
cp terraform.tfvars- terraform.tfvars
vim terraform.tfvars  # 環境に合わせて編集
terraform init
terraform apply
```

# テスト実行

```bash
./make_env.sh
```
で outputを環境変数にした `tmp/env.sh` ができるので、

- `./remote_test.sh` で正常系のテスト
- `./validator_test.sh` でバリデータのテスト


# OpenAPIのエクスポート

デプロイ後

```bash
./make_env.sh
./export_as_openapi.sh
```

で tmpの下に `oas3.json` と `oas3.yaml`(yqコマンドがあれば)ができます。


# ほかメモ

OpenAPI、レスポンスも書いてありますが、ちゃんとチェックしてない。
exportしたoas3.yamlを
[Swagger Editor](https://editor.swagger.io/)
で開けばいいはずなのであとでやる。

やってみたら URLで//devになる問題が。これAWSのAPIのほうが間違ってるような気がする。
あとexampleもどこかで消える。exportした定義からserversのとこだけ、もとの定義に(basePathの/を消して)コピペするのがいいとおもう。


# クライアントの自動生成

デプロイしたら
```bash
./make_env.sh
./export_as_openapi.sh
cp openapi.yaml tmp/
cd tmp
vim openapi.yaml oas3.yaml
# oas3.ymlのservers:の記述を openapi.yamlへコピペする。
# ただしbasepath:の/devはdevにする(最初の/を取る)
```

で、
```bash
docker run --rm -v "${PWD}:/local" openapitools/openapi-generator-cli generate \
  -i /local/openapi.yaml \
  -g python \
  -o /local/out/python
```

でコードが生成されるので
```bash
sudo chown -R ${UID} out
cd out/python
python3 setup.py install --user
```

で準備完了。`README.md` にサンプルコードがあるので、それをコピペして実行。
更に改造するには `docs/DefaultApi.md` を見る。


# スタブサーバを作る

(モックサーバともいう)

python-flaskで試したら Python Dependency Hell にハマったのでメモ。

まず、openapi,yamlのversion:のところを普通のバージョンぽいもの(1.0.0)とかにする。日付とかはダメ。

また、servers:もちゃんとURLっぽいものに編集。

こんな感じのを
```yaml
servers:
  - url: http://localhost/{basePath}
    variables:
      basePath:
        default: ${stage_name}
```

こんな感じにする
```yaml
servers:
  - url: http://localhost/{basePath}
    variables:
      basePath:
        default: dev
```

で

```bash
docker run --rm -v "${PWD}:/local" openapitools/openapi-generator-cli generate \
  -i /local/openapi-rewrite.yaml \
  -g python-flask \
  -o /local/tmp/out/python-flask
sudo chown -R $UID tmp/out
cd tmp/out/python-flask
python3.9 -m venv ../.venv-flask
. ../.venv-flask/bin/activate
# venvにしとくのが吉
vim requirements.txt
# markupsafe == 2.0.1 を追加
# Flask == 1.1.4 に変更
pip3 install --user -r requirements.txt
```
で、

```bash
python3 -m openapi_server
```
で起動して、

```bash
curl localhost:8080/dev/goodbye
```
などで、 `do some magic!` と帰ってきたら一段落。

あとは
`openapi_server/controllers/default_controller.py` の `do some magic!`を修正して本物のスタブサーバーにする。

そこそこできたらDockerにしてメンバに配布する。

とりあえず動かしたけど、なんだか不安。Flaskの1系ってもうメンテされてないのでは?
モックにしては手順が面倒なのも。もとのOpenAPIの定義が変わったらどうする?

こういうのがあるらしい。試す
[stoplightio/prism: Turn any OpenAPI2/3 and Postman Collection file into an API server with mocking, transformations and validations.](https://github.com/stoplightio/prism)
