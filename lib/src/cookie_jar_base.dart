// Copyright (c) 2016, tomcra. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

/// This library handles cookies as described in
/// https://tools.ietf.org/html/rfc6265 it should work in both client and
/// browser and includes a fairly simple interface to work with package:http

library cookies_jar;
// TODO: Put public facing types in this file.

/// Checks if you are awesome. Spoiler: you are.
class Awesome {
  bool get isAwesome => true;
}


// From RFC 6265 https://tools.ietf.org/html/rfc6265#section-4.1.1
// sane-cookie-date  = <rfc1123-date, defined in [RFC2616], Section 3.3.1>
//
// From RFC 2616 https://tools.ietf.org/html/rfc2616#section-3.3.1
// 3.3 Date/Time Formats
//
// 3.3.1 Full Date
//
// HTTP applications have historically allowed three different formats
// for the representation of date/time stamps:
//
// Sun, 06 Nov 1994 08:49:37 GMT  ; RFC 822, updated by RFC 1123
// Sunday, 06-Nov-94 08:49:37 GMT ; RFC 850, obsoleted by RFC 1036
// Sun Nov  6 08:49:37 1994       ; ANSI C's asctime() format
//
// The first format is preferred as an Internet standard and represents
// a fixed-length subset of that defined by RFC 1123 [8] (an update to
// RFC 822 [9]). The second format is in common use, but is based on the
// obsolete RFC 850 [12] date format and lacks a four-digit year.
// HTTP/1.1 clients and servers that parse the date value MUST accept
// all three formats (for compatibility with HTTP/1.0), though they MUST
// only generate the RFC 1123 format for representing HTTP-date values
// in header fields. See section 19.3 for further information.
//
// Note: Recipients of date values are encouraged to be robust in
// accepting date values that may have been sent by non-HTTP
// applications, as is sometimes the case when retrieving or posting
// messages via proxies/gateways to SMTP or NNTP.
//
//
// All HTTP date/time stamps MUST be represented in Greenwich Mean Time
// (GMT), without exception. For the purposes of HTTP, GMT is exactly
// equal to UTC (Coordinated Universal Time). This is indicated in the
// first two formats by the inclusion of "GMT" as the three-letter
// abbreviation for time zone, and MUST be assumed when reading the
// asctime format. HTTP-date is case sensitive and MUST NOT include
// additional LWS beyond that specifically included as SP in the
// grammar.
//
// HTTP-date    = rfc1123-date | rfc850-date | asctime-date
// rfc1123-date = wkday "," SP date1 SP time SP "GMT"
// rfc850-date  = weekday "," SP date2 SP time SP "GMT"
// asctime-date = wkday SP date3 SP time SP 4DIGIT
// date1        = 2DIGIT SP month SP 4DIGIT
//                ; day month year (e.g., 02 Jun 1982)
// date2        = 2DIGIT "-" month "-" 2DIGIT
//                ; day-month-year (e.g., 02-Jun-82)
// date3        = month SP ( 2DIGIT | ( SP 1DIGIT ))
//                ; month day (e.g., Jun  2)
// time         = 2DIGIT ":" 2DIGIT ":" 2DIGIT
//                ; 00:00:00 - 23:59:59
// wkday        = "Mon" | "Tue" | "Wed"
//              | "Thu" | "Fri" | "Sat" | "Sun"
// weekday      = "Monday" | "Tuesday" | "Wednesday"
//              | "Thursday" | "Friday" | "Saturday" | "Sunday"
// month        = "Jan" | "Feb" | "Mar" | "Apr"
//              | "May" | "Jun" | "Jul" | "Aug"
//              | "Sep" | "Oct" | "Nov" | "Dec"
//
// Note: HTTP requirements for the date/time stamp format apply only
// to their usage within the protocol stream. Clients and servers are
// not required to use these formats for user presentation, request
// logging, etc.
class CookieDateTime {


//   The user agent MUST use an algorithm equivalent to the following
//   algorithm to parse a cookie-date.  Note that the various boolean
//   flags defined as a part of the algorithm (i.e., found-time, found-
//   day-of-month, found-month, found-year) are initially "not set".
//
//   1.  Using the grammar below, divide the cookie-date into date-tokens.
//
//   cookie-date     = *delimiter date-token-list *delimiter
//   date-token-list = date-token *( 1*delimiter date-token )
//   date-token      = 1*non-delimiter
//
//   delimiter       = %x09 / %x20-2F / %x3B-40 / %x5B-60 / %x7B-7E
//   non-delimiter   = %x00-08 / %x0A-1F / DIGIT / ":" / ALPHA / %x7F-FF
//   non-digit       = %x00-2F / %x3A-FF
//
//   day-of-month    = 1*2DIGIT ( non-digit *OCTET )
//   month           = ( "jan" / "feb" / "mar" / "apr" /
//                       "may" / "jun" / "jul" / "aug" /
//                       "sep" / "oct" / "nov" / "dec" ) *OCTET
//   year            = 2*4DIGIT ( non-digit *OCTET )
//   time            = hms-time ( non-digit *OCTET )
//   hms-time        = time-field ":" time-field ":" time-field
//   time-field      = 1*2DIGIT
//
//   2.  Process each date-token sequentially in the order the date-tokens
//       appear in the cookie-date:
//
//       1.  If the found-time flag is not set and the token matches the
//           time production, set the found-time flag and set the hour-
//           value, minute-value, and second-value to the numbers denoted
//           by the digits in the date-token, respectively.  Skip the
//           remaining sub-steps and continue to the next date-token.
//
//       2.  If the found-day-of-month flag is not set and the date-token
//           matches the day-of-month production, set the found-day-of-
//           month flag and set the day-of-month-value to the number
//           denoted by the date-token.  Skip the remaining sub-steps and
//           continue to the next date-token.
//
//       3.  If the found-month flag is not set and the date-token matches
//           the month production, set the found-month flag and set the
//           month-value to the month denoted by the date-token.  Skip the
//           remaining sub-steps and continue to the next date-token.
//
//       4.  If the found-year flag is not set and the date-token matches
//           the year production, set the found-year flag and set the
//           year-value to the number denoted by the date-token.  Skip the
//           remaining sub-steps and continue to the next date-token.
//
//   3.  If the year-value is greater than or equal to 70 and less than or
//       equal to 99, increment the year-value by 1900.
//
//   4.  If the year-value is greater than or equal to 0 and less than or
//       equal to 69, increment the year-value by 2000.
//
//       1.  NOTE: Some existing user agents interpret two-digit years
//           differently.
//
//   5.  Abort these steps and fail to parse the cookie-date if:
//
//       *  at least one of the found-day-of-month, found-month, found-
//          year, or found-time flags is not set,
//
//       *  the day-of-month-value is less than 1 or greater than 31,
//
//       *  the year-value is less than 1601,
//
//       *  the hour-value is greater than 23,
//
//       *  the minute-value is greater than 59, or
//
//       *  the second-value is greater than 59.
//
//       (Note that leap seconds cannot be represented in this syntax.)
//
//   6.  Let the parsed-cookie-date be the date whose day-of-month, month,
//       year, hour, minute, and second (in UTC) are the day-of-month-
//       value, the month-value, the year-value, the hour-value, the
//       minute-value, and the second-value, respectively.  If no such
//       date exists, abort these steps and fail to parse the cookie-date.
//
//   7.  Return the parsed-cookie-date as the result of this algorithm.

  static DateTime parseCookieDate(String date) {
    final int SP = 32;
    const List wkdays = const ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    const List weekdays = const ["Monday", "Tuesday", "Wednesday", "Thursday",
    "Friday", "Saturday", "Sunday"
    ];
    const List months = const ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    const List wkdaysLowerCase =
    const ["mon", "tue", "wed", "thu", "fri", "sat", "sun"];
    const List weekdaysLowerCase = const ["monday", "tuesday", "wednesday",
    "thursday", "friday", "saturday",
    "sunday"
    ];
    const List monthsLowerCase = const ["jan", "feb", "mar", "apr", "may",
    "jun", "jul", "aug", "sep", "oct",
    "nov", "dec"
    ];
    RegExp delimiterMatch = new RegExp("([\\x09]|[\\x20-\\x2F]|[\\x3B-\\x40]|[\\x5B-\\x60]|[\\x7B-\\x7E])");
    RegExp nonDelimiterMatch = new RegExp("([\\x00-\\x08]|[\\x0A-\\x1F]|\\d|:|\\w|[\\x7F-\\xFF])");


    final int formatRfc1123 = 0;
    final int formatRfc850 = 1;
    final int formatAsctime = 2;

    int index = 0;
    String tmp;
    int format;

    int weekday;
    int day;
    int month;
    int year;
    int hours;
    int minutes;
    int seconds;

    void skipToNextToken([Pattern p]){
      if(p == null){
        index = date.indexOf(nonDelimiterMatch, index);
      } else {
        index = date.indexOf(p, index);
      }
    }

    void expect(String s) {
      if (date.length - index < s.length) {
        throw new CookieException("Invalid HTTP date $date");
      }
      String tmp = date.substring(index, index + s.length);
      if (tmp != s) {
        throw new CookieException("Invalid HTTP date $date");
      }
      index += s.length;
    }


    // The formatting of the weekday signals the format of the date string.
    int expectWeekday() {
      int weekday;
      int pos = date.indexOf(delimiterMatch, index);
      tmp = date.substring(index, pos);
      index = pos;
      skipToNextToken();
      weekday = wkdays.indexOf(tmp);
      if (weekday != -1) {
        return weekday;
      }
      weekday = weekdays.indexOf(tmp);
      if (weekday != -1) {
        return weekday;
      }
      throw new CookieException("Invalid cookie date string $date expecting a "
          "day of the week eg 'Mon' but got $tmp");
    }

    int expectMonth() {
      int pos = date.indexOf(delimiterMatch, index);
      tmp = date.substring(index, pos);
      index = pos;
      skipToNextToken();
      int month = months.indexOf(tmp);
      if (month != -1) return month;
      throw new CookieException("Invalid cookie date string $date expecting a "
          "month of the year eg 'Jan' but got $tmp");
    }

    int _expectNum([Pattern p]) {
      int pos;
      if(p == null){
        pos = date.indexOf(delimiterMatch, index);
      } else {
        pos = date.indexOf(p, index);
      }
      String tmp = date.substring(index, pos);
      index = pos;
      skipToNextToken();
      try {
        int value = int.parse(tmp);
        return value;
      } on FormatException catch (e) {
        throw new CookieException("Invalid cookie date string $date expecting "
            "a valid number but got '$tmp'");
      }
    }

    void expectEnd() {
      if (index != date.length) {
        throw new CookieException("Invalid HTTP date $date");
      }
    }

    int expectDay(){
      int day = _expectNum(delimiterMatch);
      return day;
    }

    int expectYear(){
      int year = _expectNum(delimiterMatch);
      if(year < 70) year+=2000;
      else if(year < 99) year+=1900;
      return year;
    }

    void expectTime(){
      hours = _expectNum(':');
      skipToNextToken(new RegExp("(\\d)"));
      minutes = _expectNum(':');
      skipToNextToken(new RegExp("(\\d)"));
      seconds = _expectNum();
      skipToNextToken();
    }

    weekday = expectWeekday();
    day = expectDay();
    month = expectMonth();
    year = expectYear();
    expectTime();
    expect("GMT");

    expectEnd();
    return new DateTime.utc(
        year,
        month + 1,
        day,
        hours,
        minutes,
        seconds,
        0);


  }

  static String formatCookieDate(DateTime date) {
    const List wkday = const ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    const List month = const ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

    DateTime d = date.toUtc();
    StringBuffer sb = new StringBuffer()
      ..write(wkday[d.weekday - 1])
      ..write(", ")
      ..write(d.day <= 9 ? "0" : "")
      ..write(d.day.toString())
      ..write(" ")
      ..write(month[d.month - 1])
      ..write(" ")
      ..write(d.year.toString())
      ..write(d.hour <= 9 ? " 0" : " ")
      ..write(d.hour.toString())
      ..write(d.minute <= 9 ? ":0" : ":")
      ..write(d.minute.toString())
      ..write(d.second <= 9 ? ":0" : ":")
      ..write(d.second.toString())
      ..write(" GMT");
    return sb.toString();
  }

}

class CookieException implements Exception{
  String description;

  CookieException(String this.description);

  String toString() => "Problem with the cookie. $description";
}

class Cookie {
  String name, value, path, domain;
  DateTime expiryTime, creationTime, lastAccessTime;
  bool secure = false;
  bool httpOnly = false;
  bool persistent = false;
  bool hostOnly = false;

  Cookie(this.name, this.value,
      {this.path: '/', this.domain: '', String maxAge: '', String expires: '',
      this.secure: false, this.httpOnly: false, this.hostOnly: false})
      : expiryTime = CookieDateTime.parseCookieDate(expires),
        creationTime = new DateTime.now(),
        lastAccessTime = new DateTime.now(){

  }


  /// Creates a single cookie from a single set-cookie [String].
  ///
  /// The details of the set-cookie string can be found in the RFC documentation
  /// https://tools.ietf.org/html/rfc6265#section-4.1.1
  Cookie.fromString(String val) {
    //
    val.split(';').every((String s) {
      switch (s.toLowerCase().trim()) {
        case "secure":
          this.secure = true;
          return true;
        case "httponly":
          this.httpOnly = true;
          return true;
        case "hostonly":
          this.hostOnly = true;
          return true;
      }


      var kv = s.split('=').map((String s) => s.trim());
      String k = kv.first,
          v = kv.last;

      switch (k.toLowerCase()) {
        case "path":
          this.path = v;
          break;
        case "domain":
          this.domain = v;
          break;
      // TODO: Fix the max-age precednece.
      // Max age takes precednece over expires as per
      // https://tools.ietf.org/html/rfc6265#section-4.1.2.2 so instead of
      // setting the [maxAge] variable it should actully set the [expires]
      // variable.
        case "max-age":
          this.expiryTime = new DateTime.now().add(new Duration(seconds: int.parse(v)));
          break;
        case "expires":
          this.expiryTime = CookieDateTime.parseCookieDate(v);
          break;
        default:
          if (this.name != null) {
            return false;
          }
          this.name = k;
          this.value = v;
      }

      return true;
    });

    creationTime = new DateTime.now();
    lastAccessTime = new DateTime.now();
  }

  String toString() => "${this.name}=${this.value}";

}

class CookieJar implements Map<String, Cookie> {
  Map<String, Cookie> cookies;

  CookieJar.from(Map<String, Cookie> other) {
    this.cookies = new Map<String, Cookie>.from(other);
  }

  CookieJar(String cookies) {
    this.cookies = new Map<String, Cookie>();

    Iterable<Match> cookieStrings = new RegExp("(?!,)(.*?)=(.*?)(?=\$|,(?! ))")
        .allMatches(cookies);
    if (cookieStrings.isEmpty)
      return;

    for (Match m in cookieStrings) {
      String match = m.group(0);
      Cookie c = new Cookie.fromString(match);
      this[c.name] = c;
    }
  }

  // TODO: Finish writing the [toCookieClientString] function.
  // This is not finished and is just used for a single client it should only
  // return values that pass the rules. eg only return cookies for the same
  // domain and path
  String toCookieClientString(String uri){
    String cookieString = "Cookie:";

    for(Cookie c in this.values){
      cookieString += "${c.name}=${c.value}";
    }

    return cookieString;
  }

  // TODO: Finish writing the [toCookiePairString] function.
  // This is not finished and is just used for a single client it should only
  // return values that pass the rules. eg only return cookies for the same
  // domain and path
  String toCookiePairString(String uri){
    String cookieString = "";
    int cookieNum = 0;

    for(Cookie c in this.values){
      if(cookieNum > 0 ) cookieString += "; ";
      cookieString += "${c.name}=${c.value}";
      cookieNum++;
    }

    return cookieString;
  }
  bool get isEmpty => this.cookies.isEmpty;

  bool get isNotEmpty => this.cookies.isNotEmpty;

  Iterable<String> get keys => this.cookies.keys;

  int get length => this.cookies.length;

  Iterable<Cookie> get values => this.cookies.values;

  void operator []=(String key, Cookie val) {
    this.cookies[key] = val;
  }

  Cookie operator [](String key) => this.cookies[key];

  void addAll(Map<String, Cookie> other) => this.cookies.addAll(other);

  void clear() => this.cookies.clear();

  bool containsKey(String key) => this.cookies.containsKey(key);

  bool containsValue(Cookie val) => this.cookies.containsValue(val);

  void forEach(void f(String key, Cookie val)) => this.cookies.forEach(f);

  Cookie putIfAbsent(String key, Cookie ifAbsent()) =>
      this.cookies.putIfAbsent(key, ifAbsent);

  Cookie remove(String key) => this.cookies.remove(key);

}


