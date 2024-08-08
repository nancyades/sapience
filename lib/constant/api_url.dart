

class AppUrl {

  static String baseUrl = "https://sapiencepublications.co.in/api";
  static String getotpUrl(String phoneno) => "$baseUrl/generate?phone=$phoneno";
  static String getloginUrl(String phoneno, String otp) => "$baseUrl/login?phone=$phoneno&otp=$otp";
  static String getbookqrUrl(String qrcode) => "$baseUrl/book-qr-code-validate?qr_code=$qrcode";
  static String getsection() => "$baseUrl/sections";
  static String getterms(String sectionid) => "$baseUrl/terms?section_id=$sectionid";
  static String getmonth(String sectionid, String termid) => "$baseUrl/months?section_id=${sectionid}&term_id=${termid}";
  static String getweek(String sectionid, String termid, String monthid) => "$baseUrl/weeks?section_id=${sectionid}&term_id=${termid}&month_id=${monthid}";
  static String getsubject(String sectionid,String termid, String monthid,String weekid) => "$baseUrl/subjects?section_id=${sectionid}&term_id=${termid}&month_id=${monthid}&week_id=${weekid}";
  static String getvideocategorey(String sectionid,String termid, String monthid,String weekid, String subjectid) => "$baseUrl/video-categories?section_id=${sectionid}&term_id=${termid}&month_id=${monthid}&week_id=${weekid}&subject_id=${subjectid}";
  static String getvideo(String sectionid,String termid, String monthid,String weekid, String subjectid, String category) => "$baseUrl/videos?section_id=${sectionid}&term_id=${termid}&month_id=${monthid}&week_id=${weekid}&subject_id=${subjectid}&category_id=${category}";
  static String getfoodcategory() => "$baseUrl/food-categories";
  static String getfooddays() => "$baseUrl/food-days";
  static String getfoodtype() => "$baseUrl/food-types";
  static String getfoodvideo(String foodcategoryid,String foodtypeid, String fooddayid) => "$baseUrl/food-videos?food_category_id=${foodcategoryid}&food_type_id=${foodtypeid}&food_day_id=${fooddayid}";
  static String setting() => "$baseUrl/settings";

  static String sildervideo() => "$baseUrl/slider-videos";







}
