// Canonical sample CSV matching the product-readme.csv column contract.
// Demonstrates inline LaTeX, UTF-8 Bangla, the l4 board level, and exam year.

const String kSampleCsvHeader =
    'external_code,title,option_1,option_2,option_3,option_4,'
    'correct_ans,level,explanation,chapter_code,exam_year';

const List<String> kSampleCsvLines = [
  kSampleCsvHeader,
  r'PHYS-CH01-0001,"$E_k = \frac{1}{2}mv^2$ সমীকরণে $v$ বোঝায় কী?","স্থানচ্যুতি","তাৎক্ষণিক বেগ","গড় ত্বরণ","ভরবেগ",2,l1,"$v$ হলো সরণের পরিবর্তনের হার।",ch01,2025',
  r'CHEM-CH01-0002,"$\text{CaCO}_3 \xrightarrow{\Delta} \text{CaO} + \text{CO}_2$ বিক্রিয়াটি কোন ধরনের?","তাপীয় বিয়োজন","জারণ-বিজলণ","সংশ্লেষণ","প্রতিস্থাপন",1,l4,"উত্তপ্ত চুনাপাথর ভেঙে CaO ও CO₂ উৎপন্ন করে।",ch01,2024',
];

String get sampleCsv => '${kSampleCsvLines.join('\n')}\n';
