import SwiftUI

struct LegalDocumentView: View {
    let title: String
    let content: String

    var body: some View {
        ScrollView {
            Text(content)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PrivacyPolicyView: View {
    private static let content = """
    うまログ（以下、「本アプリ」）は、利用者の記録や設定を端末内に保存し、競馬の記録とふり返りに役立てるためのアプリです。本ポリシーでは、本アプリが取り扱う情報とその目的をお知らせします。

    1. 取得する情報
    ・利用者が入力した記録（券種、金額、メモなど）
    ・入力スタイルや表示項目などの設定情報
    ・バックアップ作成時に利用者が書き出すCSVファイル

    2. 利用目的
    ・入力内容の保存と表示
    ・バックアップの作成・復元
    ・アプリの品質向上のための参考

    3. 外部送信・第三者提供
    本アプリは、入力された情報や設定を外部に送信しません。広告配信や外部の解析SDKも現在は使用していません。利用者が任意で作成したCSVバックアップは、保存先を含めて利用者ご自身で管理します。

    4. 保存期間と削除
    端末内に保存される情報は、本アプリを削除すると端末から消去されます。CSVバックアップは、不要になった場合に利用者ご自身で削除してください。

    5. お問い合わせ
    本ポリシーに関するお問い合わせは、App Storeの製品ページに記載の連絡先までお願いいたします。

    6. 改定
    内容を見直す場合は、本アプリ内での掲示など分かりやすい方法でお知らせします。

    制定日: 2026年1月14日
    """

    var body: some View {
        LegalDocumentView(title: "プライバシーポリシー", content: Self.content)
    }
}

struct TermsOfServiceView: View {
    private static let content = """
    本アプリをご利用いただく前に、以下の内容をご確認ください。本アプリを利用した時点で、本規約に同意いただいたものとみなします。

    1. 利用目的
    本アプリは、競馬の記録やふり返りを行うための個人利用を目的としたサービスです。法令や公序良俗に反する目的での利用はできません。

    2. 記録内容の管理
    入力内容やバックアップの管理は利用者の責任で行ってください。記録の正確性や完全性について、本アプリは保証しません。

    3. 免責事項
    本アプリの利用により生じた損害について、当方は一切の責任を負いません。必要に応じてご自身でバックアップを行ってください。

    4. サービスの変更・終了
    本アプリの機能や提供内容は、予告なく変更または終了することがあります。

    5. 規約の変更
    規約を変更する場合は、本アプリ内での掲示など分かりやすい方法でお知らせします。

    6. 準拠法
    本規約は日本法に準拠します。

    制定日: 2026年1月14日
    """

    var body: some View {
        LegalDocumentView(title: "利用規約", content: Self.content)
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicyView()
    }
}
