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
