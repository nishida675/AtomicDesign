-- 開発用データのSQL文 --
-- テーブル初期化 --
DROP TABLE IF EXISTS attendance_table;
DROP TABLE IF EXISTS holiday_request_table;
DROP TABLE IF EXISTS holiday_master;
DROP TABLE IF EXISTS timezone_update_table;
DROP TABLE IF EXISTS license_table;
DROP TABLE IF EXISTS password_history_table;
DROP TABLE IF EXISTS password_reset_table;
DROP TABLE IF EXISTS announcement_table;
DROP TABLE IF EXISTS password_history_admin_table;
DROP TABLE IF EXISTS password_reset_admin_table;
DROP TABLE IF EXISTS employee_table;
DROP TABLE IF EXISTS company_table;
DROP TABLE IF EXISTS admin_table;
-- テーブル作成 --
CREATE TABLE admin_table (
    admin_id INT NOT NULL AUTO_INCREMENT COMMENT '管理者ID',
    admin_no VARCHAR(16) NOT NULL COMMENT '管理者番号',
    admin_name VARCHAR(64) NOT NULL COMMENT '管理者名',
    email VARCHAR(255) UNIQUE NOT NULL DEFAULT '' COMMENT 'メール', 
    valid_email TINYINT DEFAULT 0 COMMENT 'メール有効フラグ：0:無効、1:有効',
    admin_pass VARCHAR(256) NOT NULL COMMENT 'パスワード',
    edit TINYINT DEFAULT 0 COMMENT 'パスワード編集フラグ：0:有効、1:削除',
    is_deleted TINYINT DEFAULT 0 COMMENT '削除フラグ：0:有効、1:削除',
    PRIMARY KEY (admin_id)
) AUTO_INCREMENT = 10 COMMENT '管理者テーブル';
CREATE TABLE company_table (
    cmp_id INT NOT NULL AUTO_INCREMENT COMMENT '所属ID',
    cmp_name VARCHAR(256) NOT NULL COMMENT '所属名',
    is_deleted TINYINT DEFAULT 0 COMMENT '削除フラグ：0:有効、1:削除',
    PRIMARY KEY (cmp_id)
) AUTO_INCREMENT = 100 COMMENT '所属テーブル';
CREATE TABLE employee_table (
    emp_id INT NOT NULL AUTO_INCREMENT COMMENT '社員ID',
    emp_no VARCHAR(16) NOT NULL COMMENT '社員番号',
    emp_name VARCHAR(64) NOT NULL COMMENT '社員名',
    cmp_id INT NOT NULL COMMENT '所属企業ID',
    email VARCHAR(255) UNIQUE COMMENT 'メール',
    valid_email TINYINT DEFAULT 0 COMMENT 'メール有効フラグ：0:無効、1:有効',
    emp_pass VARCHAR(256) NOT NULL COMMENT 'パスワード',
    edit TINYINT DEFAULT 0 COMMENT 'パスワード編集フラグ：0:有効、1:削除',
    start_time TIME NOT NULL COMMENT '始業時間',
    close_time TIME NOT NULL COMMENT '終業時間',
    annual_leave INT NOT NULL COMMENT '年次有給休暇',
    holiday_count DOUBLE(3, 1) UNSIGNED DEFAULT 0 COMMENT '有給残日数',
    is_deleted TINYINT DEFAULT 0 COMMENT '削除フラグ：0:有効、1:削除',
    PRIMARY KEY (emp_id),
    UNIQUE KEY idx_emp_no (emp_no),
    FOREIGN KEY fk_cmp_id (cmp_id) REFERENCES company_table (cmp_id) ON DELETE CASCADE ON UPDATE CASCADE
) AUTO_INCREMENT = 1000000 COMMENT '社員テーブル';
CREATE TABLE attendance_table (
    emp_id INT NOT NULL COMMENT '社員ID',
    working_date DATE NOT NULL COMMENT '出勤日',
    at_time TIME COMMENT '出勤打刻時間',
    lv_time TIME COMMENT '退勤打刻時間',
    at_edit_time TIME COMMENT '修正出勤時間',
    lv_edit_time TIME COMMENT '修正退勤時間',
    working_hours INT DEFAULT 0 COMMENT '勤務時間',
    overtime INT DEFAULT 0 COMMENT '残業時間',
    late_reason INT DEFAULT 0 COMMENT '遅刻理由：0:遅刻なし、1:遅刻あり(理由未選択)、2:交通機関遅延、3:私用による遅刻、4:体調不良による遅刻、5:公事・公務休暇による遅刻',
    early_reason INT DEFAULT 0 COMMENT '早退理由：0:遅刻なし、1:早退あり(理由未選択)、2:私用による早退、3:体調不良による早退、4:交通遮断休暇による早退、5:公事・公務休暇による早退',
    which_state INT COMMENT '出退勤フラグ：1:出勤のみ押下、2:どちらも押下、3:退勤のみ押下',
    is_fixed INT DEFAULT 0 COMMENT '編集フラグ：0:編集なし、1:出勤のみ編集、2:退勤のみ編集、3:どちらも編集あり',
    day_off INT DEFAULT 0 COMMENT '休日フラグ：0:通常出勤、1:休日出勤、2:休暇取得',
    reason VARCHAR(256) COMMENT '追加理由',
    is_deleted TINYINT DEFAULT 0 COMMENT '削除フラグ：0:有効、1:削除',
    PRIMARY KEY (emp_id, working_date),
    CONSTRAINT fk1_emp_id FOREIGN KEY (emp_id) REFERENCES employee_table (emp_id) ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT '出退勤テーブル';
CREATE TABLE holiday_request_table (
    h_req_id INT NOT NULL AUTO_INCREMENT COMMENT '休暇申請ID',
    emp_id INT NOT NULL COMMENT '社員ID',
    req_date DATE NOT NULL COMMENT '休暇申請日',
    holi_type INT NOT NULL COMMENT '休暇種別：1:有給、2:弔事、……20:副反応',
    preferred_start_date DATE NOT NULL COMMENT '休暇開始日',
    preferred_last_date DATE COMMENT '休暇終了日',
    preferred_time INT COMMENT '希望期間：0:全日休、1:午前休、2:午後休',
    leave_days DOUBLE(3, 1) UNSIGNED NOT NULL COMMENT '有給使用日数',
    reason VARCHAR(256) COMMENT '取得理由',
    accept INT DEFAULT 0 COMMENT '受理状況:0：未回答、1：受理、2：却下',
    is_read TINYINT DEFAULT 0 COMMENT '既読状況：0:未読、1:既読',
    is_deleted TINYINT DEFAULT 0 COMMENT '削除フラグ：0:有効、1:削除',
    PRIMARY KEY (emp_id, preferred_start_date),
    CONSTRAINT fk2_emp_id FOREIGN KEY (emp_id) REFERENCES employee_table (emp_id) ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE KEY HRK (h_req_id)
) AUTO_INCREMENT = 1 COMMENT '休暇申請テーブル';
CREATE TABLE timezone_update_table (
    emp_id INT NOT NULL COMMENT '社員ID',
    req_date DATE NOT NULL COMMENT '勤務時間帯変更申請日',
    current_at_time TIME NOT NULL COMMENT '現在の出勤時間',
    current_lv_time TIME NOT NULL COMMENT '現在の退勤時間',
    update_date DATE NOT NULL COMMENT '変更対応日',
    update_at_time TIME NOT NULL COMMENT '変更後の出勤時間',
    update_lv_time TIME NOT NULL COMMENT '変更後の退勤時間',
    accept INT DEFAULT 0 COMMENT '受理状況:0：未回答、1：受理、2：却下',
    is_read TINYINT DEFAULT 0 COMMENT '既読状況：0:未読、1:既読',
    is_deleted TINYINT DEFAULT 0 COMMENT '削除フラグ：0:有効、1:削除',
    PRIMARY KEY (emp_id),
    CONSTRAINT fk3_emp_id FOREIGN KEY (emp_id) REFERENCES employee_table (emp_id) ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT '勤務時間帯更新テーブル';
CREATE TABLE license_table (
    emp_id INT NOT NULL COMMENT '社員ID',
    req_date DATE NOT NULL COMMENT '資格受験申請日',
    license_name VARCHAR(256) NOT NULL COMMENT '資格名',
    exam_date DATE NOT NULL COMMENT '受験予定日',
    is_read TINYINT DEFAULT 0 COMMENT '既読状況：0:未読、1:既読',
    is_deleted TINYINT DEFAULT 0 COMMENT '削除フラグ：0:有効、1:削除',
    PRIMARY KEY (emp_id, req_date),
    CONSTRAINT fk4_emp_id FOREIGN KEY (emp_id) REFERENCES employee_table (emp_id) ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT '資格受験テーブル';
CREATE TABLE holiday_master (
    holiday_date DATE NOT NULL COMMENT '祝日年月日',
    day_of_week CHAR(1) NOT NULL COMMENT '曜日',
    holiday_name VARCHAR(16) NOT NULL COMMENT '祝日名称',
    is_deleted TINYINT DEFAULT 0 COMMENT '削除フラグ：0:有効、1:削除',
    PRIMARY KEY (holiday_date)
) COMMENT '祝日マスター';
CREATE TABLE announcement_table (
 announcement_id INT NOT NULL AUTO_INCREMENT COMMENT 'お知らせID'
 , post_date DATE NOT NULL COMMENT '投稿作成日'
 , title VARCHAR(256) NOT NULL COMMENT 'タイトル'
 , post_content VARCHAR(10000) NOT NULL COMMENT '内容'
 , cmp_id INT COMMENT '企業ID'
 , set_date DATE NOT NULL COMMENT '投稿予定日'
 , del_date DATE COMMENT '投稿削除日'
 , is_send TINYINT DEFAULT 0 COMMENT '発送状態'
 , is_fixed TINYINT DEFAULT 0 COMMENT '定時発送フラグ'
 , is_deleted TINYINT DEFAULT 0 COMMENT '削除フラグ'
 , PRIMARY KEY (announcement_id)
  , FOREIGN KEY fk_cmp_id (cmp_id) REFERENCES company_table (cmp_id)
 ) AUTO_INCREMENT = 1
 COMMENT 'お知らせテーブル';
CREATE TABLE password_history_table (
    emp_id INT NOT NULL COMMENT '社員ID',
    latest_passchange_date DATE COMMENT '最新パスワード更新日',
    emp_pass1 VARCHAR(256) COMMENT 'パスワード履歴1',
    emp_pass2 VARCHAR(256) COMMENT 'パスワード履歴2',
    emp_pass3 VARCHAR(256) COMMENT 'パスワード履歴3',
    PRIMARY KEY (emp_id),
    CONSTRAINT fk5_emp_id FOREIGN KEY (emp_id) REFERENCES employee_table (emp_id) ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT 'パスワード変更テーブル';
CREATE TABLE password_reset_table (
    emp_id INT NOT NULL COMMENT '社員ID',
    uuid VARCHAR(36) COMMENT 'UUID',
    latest_uuid_date DATETIME COMMENT '最新UUID発行タイムスタンプ',
    count INT DEFAULT 1 COMMENT '一日の発行回数:1：1回目、2：2回目、3：3回目',
    PRIMARY KEY (emp_id),
    CONSTRAINT fk6_emp_id FOREIGN KEY (emp_id) REFERENCES employee_table (emp_id) ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT 'パスワードリセットテーブル';
CREATE TABLE password_history_admin_table (
    admin_id INT NOT NULL COMMENT '管理者ID',
    latest_passchange_date DATE COMMENT '最新パスワード更新日',
    admin_pass1 VARCHAR(256) COMMENT 'パスワード履歴1',
    admin_pass2 VARCHAR(256) COMMENT 'パスワード履歴2',
    admin_pass3 VARCHAR(256) COMMENT 'パスワード履歴3',
    PRIMARY KEY (admin_id),
    CONSTRAINT fk1_admin_id FOREIGN KEY (admin_id) REFERENCES admin_table (admin_id) ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT 'パスワード変更テーブルadmin';
CREATE TABLE password_reset_admin_table (
    admin_id INT NOT NULL COMMENT '管理者ID',
    uuid VARCHAR(36) COMMENT 'UUID',
    latest_uuid_date DATETIME COMMENT '最新UUID発行タイムスタンプ',
    count INT DEFAULT 1 COMMENT '一日の発行回数:1：1回目、2：2回目、3：3回目',
    PRIMARY KEY (admin_id),
      CONSTRAINT fk2_admin_id FOREIGN KEY (admin_id) REFERENCES admin_table (admin_id) ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT 'パスワードリセットテーブルadmin';
-- データ挿入 --
-- 管理者テーブル
-- pass:12345
INSERT INTO admin_table (admin_no, admin_name, admin_pass)
VALUES (
        'admin',
        '管理者',
        'DF986B77CE35DECA2B75C66C54F213FE'
    );
-- 所属テーブル
INSERT INTO company_table (cmp_name)
VALUES ('企業A');
INSERT INTO company_table (cmp_name)
VALUES ('企業B');
INSERT INTO company_table (cmp_name)
VALUES ('企業C');
INSERT INTO company_table (cmp_name)
VALUES ('企業D');
INSERT INTO company_table (cmp_name)
VALUES ('企業E');
INSERT INTO company_table (cmp_name)
VALUES ('企業F');
INSERT INTO company_table (cmp_name)
VALUES ('企業G');
INSERT INTO company_table (cmp_name)
VALUES ('企業H');
-- 社員テーブル
INSERT INTO employee_table (
        emp_no,
        emp_name,
        cmp_id,
        emp_pass,
        start_time,
        close_time,
        annual_leave,
        holiday_count
    )
VALUES (
        'F1002000',
        '山田太郎',
        100,
        'DF986B77CE35DECA2B75C66C54F213FE',
        '09:00',
        '17:30',
        10,
        20
    );
INSERT INTO employee_table (
        emp_no,
        emp_name,
        cmp_id,
        emp_pass,
        start_time,
        close_time,
        annual_leave,
        holiday_count
    )
VALUES (
        'F1002001',
        '佐藤花子',
        107,
        'DF986B77CE35DECA2B75C66C54F213FE',
        '09:30',
        '18:00',
        11,
        20
    );
INSERT INTO employee_table (
        emp_no,
        emp_name,
        cmp_id,
        emp_pass,
        start_time,
        close_time,
        annual_leave,
        holiday_count
    )
VALUES (
        'F1002002',
        '高橋一郎',
        100,
        'DF986B77CE35DECA2B75C66C54F213FE',
        '09:00',
        '17:30',
        20,
        20
    );
-- 出退勤テーブル
INSERT INTO attendance_table (emp_id, working_date, lv_time, which_state)
VALUES (1000000, '2023-08-01', '17:36:12', 2);
INSERT INTO attendance_table (emp_id, working_date, at_time, which_state)
VALUES (1000000, '2023-08-02', '08:48:52', 1);
INSERT INTO attendance_table (
        emp_id,
        working_date,
        at_time,
        lv_time,
        working_hours,
        overtime,
        late_reason,
        which_state
    )
VALUES (
        1000000,
        '2023-08-03',
        '09:30:50',
        '17:40:44',
        430,
        10,
        0,
        3
    );
INSERT INTO attendance_table (
        emp_id,
        working_date,
        at_time,
        lv_time,
        working_hours,
        overtime,
        early_reason,
        which_state
    )
VALUES (
        1000000,
        '2023-08-04',
        '08:41:46',
        '16:30:46',
        390,
        0,
        1,
        3
    );
INSERT INTO attendance_table (emp_id, working_date, lv_time, which_state)
VALUES (1000001, '2023-08-01', '17:36:12', 2);
INSERT INTO attendance_table (emp_id, working_date, at_time, which_state)
VALUES (1000001, '2023-08-02', '08:48:52', 1);
INSERT INTO attendance_table (
        emp_id,
        working_date,
        at_time,
        lv_time,
        working_hours,
        overtime,
        late_reason,
        which_state
    )
VALUES (
        1000001,
        '2023-08-03',
        '09:30:50',
        '17:40:44',
        430,
        10,
        1,
        3
    );
INSERT INTO attendance_table (
        emp_id,
        working_date,
        at_time,
        lv_time,
        working_hours,
        overtime,
        early_reason,
        which_state
    )
VALUES (
        1000001,
        '2023-08-04',
        '08:41:46',
        '16:30:46',
        390,
        0,
        1,
        3
    );
-- 休暇申請テーブル
INSERT INTO holiday_request_table (
        emp_id,
        req_date,
        holi_type,
        preferred_start_date,
        preferred_time,
        leave_days,
        reason
    )
VALUES (
        1000000,
        '2023-07-11',
        1,
        '2023-07-14',
        0,
        1,
        '私用のため'
    );
INSERT INTO holiday_request_table (
        emp_id,
        req_date,
        holi_type,
        preferred_start_date,
        preferred_time,
        leave_days,
        reason,
        accept
    )
VALUES (
        1000000,
        '2023-07-05',
        1,
        '2023-07-07',
        1,
        0.5,
        '通院のため',
        1
    );
INSERT INTO holiday_request_table (
        emp_id,
        req_date,
        holi_type,
        preferred_start_date,
        preferred_last_date,
        leave_days,
        reason
    )
VALUES (
        1000001,
        '2023-07-03',
        1,
        '2023-07-25',
        '2023-07-27',
        3,
        '私用のため'
    );
-- 勤務時間帯更新テーブル
INSERT INTO timezone_update_table (
        emp_id,
        req_date,
        current_at_time,
        current_lv_time,
        update_date,
        update_at_time,
        update_lv_time,
        accept,
        is_read
    )
VALUES (
        1000001,
        '2023-08-01',
        '09:00:00',
        '17:30:00',
        '2023-09-01',
        '09:30:00',
        '18:00:00',
        1,
        0
    );
-- 資格受験テーブル
INSERT INTO license_table (
        emp_id,
        req_date,
        license_name,
        exam_date,
        is_read
    )
VALUES (
        1000000,
        '2022-12-01',
        'ITパスポート',
        '2023-01-29',
        1
    );
INSERT INTO license_table (
        emp_id,
        req_date,
        license_name,
        exam_date,
        is_read
    )
VALUES (
        1000000,
        '2023-04-01',
        '基本情報技術者試験(FE)',
        '2023-06-25',
        1
    );
INSERT INTO license_table (emp_id, req_date, license_name, exam_date)
VALUES (
        1000000,
        '2023-07-24',
        '応用情報技術者試験(AP)',
        '2023-10-08'
    );
INSERT INTO license_table (
        emp_id,
        req_date,
        license_name,
        exam_date,
        is_read
    )
VALUES (1000001, '2022-11-01', 'CCNA', '2023-01-29', 1);
INSERT INTO license_table (
        emp_id,
        req_date,
        license_name,
        exam_date,
        is_read
    )
VALUES (1000001, '2023-04-01', 'CCNA', '2023-05-28', 1);
INSERT INTO license_table (emp_id, req_date, license_name, exam_date)
VALUES (
        1000001,
        '2023-06-01',
        'CCNP Security',
        '2023-10-29'
    );
-- 祝日マスター
INSERT INTO holiday_master (holiday_date, day_of_week, holiday_name)
VALUES ('2023-01-02', '月', '振替休日');
INSERT INTO holiday_master (holiday_date, day_of_week, holiday_name)
VALUES ('2023-01-03', '火', 'エボルバ休日');
INSERT INTO announcement_table (post_date, title, post_content,set_date, is_fixed, is_send)
 VALUES ('2023-10-10', '【ITS限定周知】UdemyBusinessページ更新のお知らせ', 'UdemyBusinessページ更新いたしましたので、お知らせいたします(^^)/
ーーーーーーーーーーーーーーーーーーーーー
■更新内容■
・コンテンツ一覧更新⇒日本語新講座「58」追加有
・10月度ニュースレター掲載
今回は時間がなく、紹介講座等をこのお知らせには記載しませんが、
今月号のニュースレターより下記情報が追加されています！
是非ご参考にしてみてください!(^^)!
「Udemy講座の人気講師のご紹介」
「人気検索キーワードのご紹介」
今回のお知らせは短いですが以上となります。
おすすめ講座マップのPDFデータや講座一覧やニュースレポート等々
UdemyBusinessについての詳細、利用方法については下記「内部リンク」をご覧ください(´▽｀)
よろしくお願いします<(_ _)>
---------------問い合わせ先--------------
ITS事業企画部　ITS人財開発ユニット
UB担当
MAIL:its-kyouiku@altius-link.com
----------------------------------------------', '2023-10-11', 0, 1);
INSERT INTO announcement_table (post_date, title, post_content, set_date, is_fixed, is_send)
 VALUES ('2023-10-10', '【ニュースリリース】在宅コールセンターで遠隔地から柔軟に働く「ひとり親世帯・Wワークの地方雇用推進」プロジェクト', '▼タイトル
在宅コールセンターで遠隔地から柔軟に働く「ひとり親世帯・Wワークの地方雇用推進」プロジェクト
沖縄セルラー、アサイアン、KDDIエボルバが共同でリモート就業を実証
▼コーポレートサイト内ニュースリリースの閲覧について
「外部リンク」よりご覧いただけます。
---------------問い合わせ先--------------
広報G
広報担当
MAIL:adv@k-evolva.com
----------------------------------------------', '2023-10-12', 0, 1);
 
 
INSERT INTO announcement_table (post_date, title, post_content,set_date, is_fixed, is_send)
 VALUES ('2023-10-10', '(お知らせ１)【重要なご案内 / 復旧報】 一部金融機関への給与支払い遅延状況の解消について', '件　名　 ：【重要なご案内 / 復旧報】 一部金融機関への給与支払い遅延状況の解消について
発信日　 ：2023年10月12日
発信部署 ：アルティウスリンク株式会社 経営管理統括本部 経営管理本部 財務経理部
宛　先 　：給与支払日が毎月15日であるアルティウスリンク従業員*1のうち、
以下の金融機関を給与振込先としている方（下記以外の金融機関をご利用の方は対象外）
--------------------------------------------------------------------------------
【対象金融機関：以下の10行*2】
りそな銀行、埼玉りそな銀行、関西みらい銀行、山口銀行、北九州銀行、三菱UFJ 信託銀行、
日本カストディ銀行、JP モルガン・チェース銀行、もみじ銀行、商工組合中央金庫
--------------------------------------------------------------------------------
昨日ご案内いたしました全国銀行資金決済ネットワーク（全銀ネット）のシステム障害による、対象金融機関10行に対する振込入金の遅延が解消しましたので続報をご案内します。
全銀ネットより、システム障害は本日朝までに復旧し、安定稼働中であるとの発表がありました。また、当社の取引銀行からも通常の取引を再開したとの案内を受けました。
ご心配をお掛けいたしましたが、上記の対象金融機関で給与を受け取られる皆様について、今月の給与支払い日である10月13日（金）中*3*4に給与の振り込みができることとなりましたのでご連絡申し上げます。
ご不明な点がございましたら、下記の問合せ窓口までご連絡ください。
【問合せ先窓口】給与保険部
・旧KDDIエボルバ社員向け
給与第1ユニット　e-mail：kyuyo@altius-link.com
・旧りらいあコミュニケーションズ社員向け
給与第2ユニット　e-mail：kyuyo_rck@altius-link.com
---------------問い合わせ先--------------
給与第1ユニット/ 給与第2ユニット
給与第1・２U
TEL:kyuyo@altius-link.co
MAIL:kyuyo_rck@altius-link.com
----------------------------------------------', '2023-10-13', 0, 1);
 
 INSERT INTO announcement_table (post_date, title, post_content,set_date, is_fixed, is_send)
 VALUES ('2023-10-10', '【ニュースリリース】KDDIエボルバとりらいあコミュニケーションズ、統合会社アルティウスリンクを発足', '▼タイトル
KDDIエボルバとりらいあコミュニケーションズ、統合会社アルティウスリンクを発足 〜デジタルBPOで高みを目指し信頼のパートナーへ〜
▼コーポレートサイト内ニュースリリースの閲覧について
「外部リンク」よりご覧いただけます。
---------------問い合わせ先--------------
経営戦略本部 広報室
広報担当
MAIL:adv@k-evolva.com
----------------------------------------------', '2023-10-14', 0, 1);
 
  INSERT INTO announcement_table (post_date, title, post_content,set_date, is_fixed, is_send)
 VALUES ('2023-10-10', '【周知】：ウォーキングイベント参加者100名様にデジタルギフトを配布します！！', '皆様、かなり暑い日が続いておりますが、
いかがお過ごしですか？
日中39℃となる地域も出てきており、
全国的に熱中症となるリスクがとても高いです！
こまめに水分・塩分を摂り、
涼しいところへ移動するなどしてくださいね。
日傘も有効です！
熱中症は命にも関わるので、命第一で行動しましょう！
さて今回6/28(水)〜7/7(金)で開催されました
ウォーキングイベント！当社は…
＝＝＝＝＝
たくさん参加したで賞　第2位
＝＝＝＝＝
を受賞しました♪
暑い中、ご参加いただきありがとうございました！
さて受賞により
全国のセブン‐イレブンのお店で引き換えられる 7プレミアム お茶 600ML
デジタルギフト100個を贈呈されております！！
イベントに参加いただいた方の中から
以下条件で抽出した100名様に
登録いただいたメールアドレスへデジタルギフトを配布いたします。
*配布する対象者は、以下の条件で決定しております。
①　イベント期間中：3,000歩/1日達成日数上位者
　　　　　　　　　×
②　イベント期間中：総歩数上位者
配布対象者には、2023年8月4日までに
【well-prom@k-evolva.com】より
「aruku＆」アプリに登録いただいたメールアドレスへ
ギフト引き換え用のURLが届きます。
*届かなかった場合は配布対象者外となりますので、ご了承ください。
メールを受信された方は是非、
お茶と交換し、喉を潤してくださいませ！
---------------問い合わせ先--------------
ウェルネス推進G
イベント担当
MAIL:well-prom@k-evolva.com
----------------------------------------------', '2023-10-15', 0, 1);
 
 
 
 
 
 
 
INSERT INTO announcement_table (post_date, title, post_content, cmp_id, set_date, is_fixed, is_send)
 VALUES ('2023-10-15', '【企業A限定周知】UdemyBusinessページ更新のお知らせ', 'UdemyBusinessページ更新いたしました。
ーーーーーーーーーーーーーーーーーーーーー
■更新内容■
・コンテンツ一覧更新⇒新講座「34」追加有
・3月度ニュースレター掲載　※2023年03月(pdf)
＜ニュースレター目次＞
１：3月の新着講座（34件）
「情報処理安全確保支援士試験：過去問題演習」を学習できるコンテンツが新登場
２：2月のスキル別 人気講座ランキング
Techスキル／Businessスキル別TOP10講座紹介
３：編集者おすすめ講座
良いリーダーでありたい方向けの講座特集
■講座紹介■
＜講座名：専用URL＞
『起業も資格も語学習得も自由自在！逆算思考による目標達成術マスターコース』
https://k-evolva.udemy.com/course/yvuuvjcu/learn/lecture/19864054#overview
※SMART法には様々な解釈があるため講師解釈版とはなりますが、会社も目標設定時に推奨している『SMART法』についての知見を広げることができる有益な講座であると考えます。
＜本講座の特徴＞
資格や才能がなくても、『なりたい』自分になれる目標達成術が学べます。精神論ではなく、講師の解釈による『SMART法』での目標設定と『逆算思考』により、無理なく最小の労力で目標達成へと導きます。講座の途中で学びを実践できるワークおよびその解説もついており、実際の行動に移しやすいコース構成となっております。今度こそ、立てっぱなしの目標を達成したいあなたにオススメします。
＜受講者の声＞
目標の立て方や詳細な設定まで分かりやすく解説されており分かりやすかった。
目標設定や実行計画についてより実践的な手法を学ぶことができました。特に陥りやすいスタックポイントに対する対処法が豊富だったのでこれなら自分でも実行できそうだと感じることができました。
※レビュー評価（3/22時点）・・・５星評価中「平均4.3星」と非常に高評価の講座です。ご興味ある方はぜひ受講されてみてはいかがでしょうか。
＝＝＝＝＝＝＝＝＝＝＝＝
UdemyBusinessについての詳細や、
利用方法については下記「内部リンク」をご覧ください(´▽｀)
---------------問い合わせ先--------------
ITSHRM部　ITS人財開発G
UB担当
MAIL:its-kyouiku@k-evolva.com
----------------------------------------------', 100, '2023-10-16', 0, 1);
 
INSERT INTO announcement_table (post_date, title, post_content, cmp_id, set_date, is_fixed, is_send)
 VALUES ('2023-10-15', '【企業B限定周知】UdemyBusinessページ更新のお知らせ', 'UdemyBusinessページ更新いたしました。
ーーーーーーーーーーーーーーーーーーーーー
■更新内容■
・コンテンツ一覧更新⇒新講座「34」追加有
・3月度ニュースレター掲載　※2023年03月(pdf)
＜ニュースレター目次＞
１：3月の新着講座（34件）
「情報処理安全確保支援士試験：過去問題演習」を学習できるコンテンツが新登場
２：2月のスキル別 人気講座ランキング
Techスキル／Businessスキル別TOP10講座紹介
３：編集者おすすめ講座
良いリーダーでありたい方向けの講座特集
■講座紹介■
＜講座名：専用URL＞
『起業も資格も語学習得も自由自在！逆算思考による目標達成術マスターコース』
https://k-evolva.udemy.com/course/yvuuvjcu/learn/lecture/19864054#overview
※SMART法には様々な解釈があるため講師解釈版とはなりますが、会社も目標設定時に推奨している『SMART法』についての知見を広げることができる有益な講座であると考えます。
＜本講座の特徴＞
資格や才能がなくても、『なりたい』自分になれる目標達成術が学べます。精神論ではなく、講師の解釈による『SMART法』での目標設定と『逆算思考』により、無理なく最小の労力で目標達成へと導きます。講座の途中で学びを実践できるワークおよびその解説もついており、実際の行動に移しやすいコース構成となっております。今度こそ、立てっぱなしの目標を達成したいあなたにオススメします。
＜受講者の声＞
目標の立て方や詳細な設定まで分かりやすく解説されており分かりやすかった。
目標設定や実行計画についてより実践的な手法を学ぶことができました。特に陥りやすいスタックポイントに対する対処法が豊富だったのでこれなら自分でも実行できそうだと感じることができました。
※レビュー評価（3/22時点）・・・５星評価中「平均4.3星」と非常に高評価の講座です。ご興味ある方はぜひ受講されてみてはいかがでしょうか。
＝＝＝＝＝＝＝＝＝＝＝＝
UdemyBusinessについての詳細や、
利用方法については下記「内部リンク」をご覧ください(´▽｀)
---------------問い合わせ先--------------
ITSHRM部　ITS人財開発G
UB担当
MAIL:its-kyouiku@k-evolva.com
----------------------------------------------', 101, '2023-10-16', 0, 1);
 
INSERT INTO announcement_table (post_date, title, post_content, cmp_id, set_date, is_fixed, is_send)
 VALUES ('2023-10-15', '【企業C限定周知】UdemyBusinessページ更新のお知らせ', 'UdemyBusinessページ更新いたしました。
ーーーーーーーーーーーーーーーーーーーーー
■更新内容■
・コンテンツ一覧更新⇒新講座「34」追加有
・3月度ニュースレター掲載　※2023年03月(pdf)
＜ニュースレター目次＞
１：3月の新着講座（34件）
「情報処理安全確保支援士試験：過去問題演習」を学習できるコンテンツが新登場
２：2月のスキル別 人気講座ランキング
Techスキル／Businessスキル別TOP10講座紹介
３：編集者おすすめ講座
良いリーダーでありたい方向けの講座特集
■講座紹介■
＜講座名：専用URL＞
『起業も資格も語学習得も自由自在！逆算思考による目標達成術マスターコース』
https://k-evolva.udemy.com/course/yvuuvjcu/learn/lecture/19864054#overview
※SMART法には様々な解釈があるため講師解釈版とはなりますが、会社も目標設定時に推奨している『SMART法』についての知見を広げることができる有益な講座であると考えます。
＜本講座の特徴＞
資格や才能がなくても、『なりたい』自分になれる目標達成術が学べます。精神論ではなく、講師の解釈による『SMART法』での目標設定と『逆算思考』により、無理なく最小の労力で目標達成へと導きます。講座の途中で学びを実践できるワークおよびその解説もついており、実際の行動に移しやすいコース構成となっております。今度こそ、立てっぱなしの目標を達成したいあなたにオススメします。
＜受講者の声＞
目標の立て方や詳細な設定まで分かりやすく解説されており分かりやすかった。
目標設定や実行計画についてより実践的な手法を学ぶことができました。特に陥りやすいスタックポイントに対する対処法が豊富だったのでこれなら自分でも実行できそうだと感じることができました。
※レビュー評価（3/22時点）・・・５星評価中「平均4.3星」と非常に高評価の講座です。ご興味ある方はぜひ受講されてみてはいかがでしょうか。
＝＝＝＝＝＝＝＝＝＝＝＝
UdemyBusinessについての詳細や、
利用方法については下記「内部リンク」をご覧ください(´▽｀)
---------------問い合わせ先--------------
ITSHRM部　ITS人財開発G
UB担当
MAIL:its-kyouiku@k-evolva.com
----------------------------------------------', 102, '2023-10-16', 0, 1);
 
INSERT INTO announcement_table (post_date, title, post_content, cmp_id, set_date, is_fixed, is_send)
 VALUES ('2023-10-15', '【企業D限定周知】UdemyBusinessページ更新のお知らせ', 'UdemyBusinessページ更新いたしました。
ーーーーーーーーーーーーーーーーーーーーー
■更新内容■
・コンテンツ一覧更新⇒新講座「34」追加有
・3月度ニュースレター掲載　※2023年03月(pdf)
＜ニュースレター目次＞
１：3月の新着講座（34件）
「情報処理安全確保支援士試験：過去問題演習」を学習できるコンテンツが新登場
２：2月のスキル別 人気講座ランキング
Techスキル／Businessスキル別TOP10講座紹介
３：編集者おすすめ講座
良いリーダーでありたい方向けの講座特集
■講座紹介■
＜講座名：専用URL＞
『起業も資格も語学習得も自由自在！逆算思考による目標達成術マスターコース』
https://k-evolva.udemy.com/course/yvuuvjcu/learn/lecture/19864054#overview
※SMART法には様々な解釈があるため講師解釈版とはなりますが、会社も目標設定時に推奨している『SMART法』についての知見を広げることができる有益な講座であると考えます。
＜本講座の特徴＞
資格や才能がなくても、『なりたい』自分になれる目標達成術が学べます。精神論ではなく、講師の解釈による『SMART法』での目標設定と『逆算思考』により、無理なく最小の労力で目標達成へと導きます。講座の途中で学びを実践できるワークおよびその解説もついており、実際の行動に移しやすいコース構成となっております。今度こそ、立てっぱなしの目標を達成したいあなたにオススメします。
＜受講者の声＞
目標の立て方や詳細な設定まで分かりやすく解説されており分かりやすかった。
目標設定や実行計画についてより実践的な手法を学ぶことができました。特に陥りやすいスタックポイントに対する対処法が豊富だったのでこれなら自分でも実行できそうだと感じることができました。
※レビュー評価（3/22時点）・・・５星評価中「平均4.3星」と非常に高評価の講座です。ご興味ある方はぜひ受講されてみてはいかがでしょうか。
＝＝＝＝＝＝＝＝＝＝＝＝
UdemyBusinessについての詳細や、
利用方法については下記「内部リンク」をご覧ください(´▽｀)
---------------問い合わせ先--------------
ITSHRM部　ITS人財開発G
UB担当
MAIL:its-kyouiku@k-evolva.com
----------------------------------------------', 103, '2023-10-16', 0, 1);
 
INSERT INTO announcement_table (post_date, title, post_content, cmp_id, set_date, is_fixed, is_send)
 VALUES ('2023-10-15', '【企業E限定周知】UdemyBusinessページ更新のお知らせ', 'UdemyBusinessページ更新いたしました。
ーーーーーーーーーーーーーーーーーーーーー
■更新内容■
・コンテンツ一覧更新⇒新講座「34」追加有
・3月度ニュースレター掲載　※2023年03月(pdf)
＜ニュースレター目次＞
１：3月の新着講座（34件）
「情報処理安全確保支援士試験：過去問題演習」を学習できるコンテンツが新登場
２：2月のスキル別 人気講座ランキング
Techスキル／Businessスキル別TOP10講座紹介
３：編集者おすすめ講座
良いリーダーでありたい方向けの講座特集
■講座紹介■
＜講座名：専用URL＞
『起業も資格も語学習得も自由自在！逆算思考による目標達成術マスターコース』
https://k-evolva.udemy.com/course/yvuuvjcu/learn/lecture/19864054#overview
※SMART法には様々な解釈があるため講師解釈版とはなりますが、会社も目標設定時に推奨している『SMART法』についての知見を広げることができる有益な講座であると考えます。
＜本講座の特徴＞
資格や才能がなくても、『なりたい』自分になれる目標達成術が学べます。精神論ではなく、講師の解釈による『SMART法』での目標設定と『逆算思考』により、無理なく最小の労力で目標達成へと導きます。講座の途中で学びを実践できるワークおよびその解説もついており、実際の行動に移しやすいコース構成となっております。今度こそ、立てっぱなしの目標を達成したいあなたにオススメします。
＜受講者の声＞
目標の立て方や詳細な設定まで分かりやすく解説されており分かりやすかった。
目標設定や実行計画についてより実践的な手法を学ぶことができました。特に陥りやすいスタックポイントに対する対処法が豊富だったのでこれなら自分でも実行できそうだと感じることができました。
※レビュー評価（3/22時点）・・・５星評価中「平均4.3星」と非常に高評価の講座です。ご興味ある方はぜひ受講されてみてはいかがでしょうか。
＝＝＝＝＝＝＝＝＝＝＝＝
UdemyBusinessについての詳細や、
利用方法については下記「内部リンク」をご覧ください(´▽｀)
---------------問い合わせ先--------------
ITSHRM部　ITS人財開発G
UB担当
MAIL:its-kyouiku@k-evolva.com
----------------------------------------------', 104, '2023-10-16', 0, 1);
 
INSERT INTO announcement_table (post_date, title, post_content, cmp_id, set_date, is_fixed, is_send)
 VALUES ('2023-10-15', '【企業F限定周知】UdemyBusinessページ更新のお知らせ', 'UdemyBusinessページ更新いたしました。
ーーーーーーーーーーーーーーーーーーーーー
■更新内容■
・コンテンツ一覧更新⇒新講座「34」追加有
・3月度ニュースレター掲載　※2023年03月(pdf)
＜ニュースレター目次＞
１：3月の新着講座（34件）
「情報処理安全確保支援士試験：過去問題演習」を学習できるコンテンツが新登場
２：2月のスキル別 人気講座ランキング
Techスキル／Businessスキル別TOP10講座紹介
３：編集者おすすめ講座
良いリーダーでありたい方向けの講座特集
■講座紹介■
＜講座名：専用URL＞
『起業も資格も語学習得も自由自在！逆算思考による目標達成術マスターコース』
https://k-evolva.udemy.com/course/yvuuvjcu/learn/lecture/19864054#overview
※SMART法には様々な解釈があるため講師解釈版とはなりますが、会社も目標設定時に推奨している『SMART法』についての知見を広げることができる有益な講座であると考えます。
＜本講座の特徴＞
資格や才能がなくても、『なりたい』自分になれる目標達成術が学べます。精神論ではなく、講師の解釈による『SMART法』での目標設定と『逆算思考』により、無理なく最小の労力で目標達成へと導きます。講座の途中で学びを実践できるワークおよびその解説もついており、実際の行動に移しやすいコース構成となっております。今度こそ、立てっぱなしの目標を達成したいあなたにオススメします。
＜受講者の声＞
目標の立て方や詳細な設定まで分かりやすく解説されており分かりやすかった。
目標設定や実行計画についてより実践的な手法を学ぶことができました。特に陥りやすいスタックポイントに対する対処法が豊富だったのでこれなら自分でも実行できそうだと感じることができました。
※レビュー評価（3/22時点）・・・５星評価中「平均4.3星」と非常に高評価の講座です。ご興味ある方はぜひ受講されてみてはいかがでしょうか。
＝＝＝＝＝＝＝＝＝＝＝＝
UdemyBusinessについての詳細や、
利用方法については下記「内部リンク」をご覧ください(´▽｀)
---------------問い合わせ先--------------
ITSHRM部　ITS人財開発G
UB担当
MAIL:its-kyouiku@k-evolva.com
----------------------------------------------', 105, '2023-10-16', 0, 1);
 
INSERT INTO announcement_table (post_date, title, post_content, cmp_id, set_date, is_fixed, is_send)
 VALUES ('2023-10-15', '【企業G限定周知】UdemyBusinessページ更新のお知らせ', 'UdemyBusinessページ更新いたしました。
ーーーーーーーーーーーーーーーーーーーーー
■更新内容■
・コンテンツ一覧更新⇒新講座「34」追加有
・3月度ニュースレター掲載　※2023年03月(pdf)
＜ニュースレター目次＞
１：3月の新着講座（34件）
「情報処理安全確保支援士試験：過去問題演習」を学習できるコンテンツが新登場
２：2月のスキル別 人気講座ランキング
Techスキル／Businessスキル別TOP10講座紹介
３：編集者おすすめ講座
良いリーダーでありたい方向けの講座特集
■講座紹介■
＜講座名：専用URL＞
『起業も資格も語学習得も自由自在！逆算思考による目標達成術マスターコース』
https://k-evolva.udemy.com/course/yvuuvjcu/learn/lecture/19864054#overview
※SMART法には様々な解釈があるため講師解釈版とはなりますが、会社も目標設定時に推奨している『SMART法』についての知見を広げることができる有益な講座であると考えます。
＜本講座の特徴＞
資格や才能がなくても、『なりたい』自分になれる目標達成術が学べます。精神論ではなく、講師の解釈による『SMART法』での目標設定と『逆算思考』により、無理なく最小の労力で目標達成へと導きます。講座の途中で学びを実践できるワークおよびその解説もついており、実際の行動に移しやすいコース構成となっております。今度こそ、立てっぱなしの目標を達成したいあなたにオススメします。
＜受講者の声＞
目標の立て方や詳細な設定まで分かりやすく解説されており分かりやすかった。
目標設定や実行計画についてより実践的な手法を学ぶことができました。特に陥りやすいスタックポイントに対する対処法が豊富だったのでこれなら自分でも実行できそうだと感じることができました。
※レビュー評価（3/22時点）・・・５星評価中「平均4.3星」と非常に高評価の講座です。ご興味ある方はぜひ受講されてみてはいかがでしょうか。
＝＝＝＝＝＝＝＝＝＝＝＝
UdemyBusinessについての詳細や、
利用方法については下記「内部リンク」をご覧ください(´▽｀)
---------------問い合わせ先--------------
ITSHRM部　ITS人財開発G
UB担当
MAIL:its-kyouiku@k-evolva.com
----------------------------------------------', 106, '2023-10-16', 0, 1);
 
INSERT INTO announcement_table (post_date, title, post_content, cmp_id, set_date, is_fixed, is_send)
 VALUES ('2023-10-15', '【企業H限定周知】UdemyBusinessページ更新のお知らせ', 'UdemyBusinessページ更新いたしました。
ーーーーーーーーーーーーーーーーーーーーー
■更新内容■
・コンテンツ一覧更新⇒新講座「34」追加有
・3月度ニュースレター掲載　※2023年03月(pdf)
＜ニュースレター目次＞
１：3月の新着講座（34件）
「情報処理安全確保支援士試験：過去問題演習」を学習できるコンテンツが新登場
２：2月のスキル別 人気講座ランキング
Techスキル／Businessスキル別TOP10講座紹介
３：編集者おすすめ講座
良いリーダーでありたい方向けの講座特集
■講座紹介■
＜講座名：専用URL＞
『起業も資格も語学習得も自由自在！逆算思考による目標達成術マスターコース』
https://k-evolva.udemy.com/course/yvuuvjcu/learn/lecture/19864054#overview
※SMART法には様々な解釈があるため講師解釈版とはなりますが、会社も目標設定時に推奨している『SMART法』についての知見を広げることができる有益な講座であると考えます。
＜本講座の特徴＞
資格や才能がなくても、『なりたい』自分になれる目標達成術が学べます。精神論ではなく、講師の解釈による『SMART法』での目標設定と『逆算思考』により、無理なく最小の労力で目標達成へと導きます。講座の途中で学びを実践できるワークおよびその解説もついており、実際の行動に移しやすいコース構成となっております。今度こそ、立てっぱなしの目標を達成したいあなたにオススメします。
＜受講者の声＞
目標の立て方や詳細な設定まで分かりやすく解説されており分かりやすかった。
目標設定や実行計画についてより実践的な手法を学ぶことができました。特に陥りやすいスタックポイントに対する対処法が豊富だったのでこれなら自分でも実行できそうだと感じることができました。
※レビュー評価（3/22時点）・・・５星評価中「平均4.3星」と非常に高評価の講座です。ご興味ある方はぜひ受講されてみてはいかがでしょうか。
＝＝＝＝＝＝＝＝＝＝＝＝
UdemyBusinessについての詳細や、
利用方法については下記「内部リンク」をご覧ください(´▽｀)
---------------問い合わせ先--------------
ITSHRM部　ITS人財開発G
UB担当
MAIL:its-kyouiku@k-evolva.com
----------------------------------------------', 107, '2023-10-16', 0, 1);
-- データ挿入終了 --