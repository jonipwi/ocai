String Langu0 = "Error Uploading Image|Deleted|STORY|Uploading Posting Image|Uploading Image|Stop record audio|Start record audio|Ticket copied|START YOUR|JOURNEY|All|Flesh|Spirit|hours ago|days ago|weeks ago|This version is for Educational Purposes|version|Community|Enter image description|meditation|pray|spiritual|mins ago|For God hath not given us the spirit of fear; but of power, and of love, and of a sound mind. 2 Timothy 1:7|Followers|Following|Posts|Bio|Edit Bio|Describe your story here|Hello, how may I help you|";
String Langu1 = "Kesalahan Mengunggah Gambar|Dihapus|CERITA|Mengunggah Gambar Posting|Mengunggah Gambar|Berhenti merekam audio|Mulai merekam audio|Tiket disalin|PERJALANAN|ANDA|Semua|Daging|Roh|jam lalu|hari lalu|minggu lalu|Versi ini untuk Tujuan Pendidikan|versi|Komunitas|Masukkan deskripsi gambar|meditasi|doa|spiritual|menit lalu|Karena Allah tidak memberikan kepada kita roh ketakutan, melainkan roh kekuatan, dan kasih, dan pikiran yang sehat. 2 Timotius 1:7|Pengikut|Mengikuti|Postingan|Bio|Edit Bio|Jelaskan ceritamu di sini|Halo, bagaimana saya bisa membantu Anda|";
String Langu2 = "上传图片错误|已删除|故事|正在上传发布图片|正在上传图片|停止录音|开始录音|复制票据|开始您的|旅程|所有|肉体|灵魂|几小时前|几天前|几周前|此版本仅用于教育目的|版本|社区|输入图片描述|冥想|祈祷|灵性|几分钟前|因为神赐给我们的不是胆怯的心，乃是刚强、仁爱和谨守的心。提摩太后书1:7|关注者|正在关注|帖子|个人简介|编辑|在这里描述您的故事|您好，我可以如何帮助您|";
String Langu3 = "이미지 업로드 오류|삭제됨|스토리|이미지 게시 업로드 중|이미지 업로드 중|오디오 녹음 중지|오디오 녹음 시작|티켓이 복사되었습니다|여정을|시작하세요|모두|육체|영혼|몇 시간 전|몇 일 전|몇 주 전|이 버전은 교육 목적을 위한 것입니다|버전|커뮤니티|이미지 설명 입력|명상|기도|영적인|몇 분 전|하나님이 우리에게 두려움의 영을 주시지 않았으니, 권능과 사랑과 절제된 마음의 영을 주셨습니다. 디모데후서 1장 7절|팔로워|팔로잉|게시물|바이오|편집|여기에 이야기를 설명하세요|안녕하세요, 어떻게 도와드릴까요|";
String Langu4 = "画像のアップロードエラー|削除済み|ストーリー|画像の投稿をアップロード中|画像のアップロード中|録音を停止する|録音を開始する|チケットがコピーされました|あなたの旅を|始めましょう|すべて|肉|霊|数時間前|数日前|数週間前|このバージョンは教育目的のためです|バージョン|コミュニティ|画像の説明を入力してください|瞑想|祈り|霊的な|数分前|神は私たちに臆する霊ではなく、力と愛と正気の霊を与えてください。テモテヨ１：７|フォロワー|フォロー中|投稿|バイオ|を編集する|ここにあなたの物語を説明してください|こんにちは、どのようにお手伝いできますか|";

const langTTS = [
  'en-AU',
  'id-ID',
  'zh-CN',
  'ko-KR',
  'ja-JP',
];

const langGPT = [
  'en',
  'id',
  'zh-cn',
  'ko',
  'ja',
];

String Langua(int idx) {
  switch(idx) {
    case 0: return Langu0;
    case 1: return Langu1;
    case 2: return Langu2;
    case 3: return Langu3;
    case 4: return Langu4;
    default: return Langu0;
  }
}

class Country {
  final int id;
  final String name;
  final String flag;

  Country({required this.id, required this.name, required this.flag});
}

String supportedLocales = "English [en]|Indonesia [id]|Chinese [cn]|Korean [kr]|Japanese [jp]";

int langIdx = 0;

String Langu = Langua(langIdx);
List LangEN = Langu.split("|");
