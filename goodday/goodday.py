"""
The MIT License

Copyright (c) <year> <copyright holders>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.



goodday.py is a simple and expressive date library for Python.
"""

import datetime

SECONDS_IN_AN_HOUR = 60 * 60
SECONDS_IN_A_DAY = 24 * SECONDS_IN_AN_HOUR
SECONDS_IN_A_YEAR = 365 * SECONDS_IN_A_DAY
class DateFormat(object):
    """
    DateFormat class is used to format or parse dates according to a format specification.
    See the documentation for datetime.datetime.strftime for information for the format specification.
    """
    def __init__(self, fmt):
        self.fmt = fmt
        
    def parse(self, str):
        """
        Parse a date in this format.
        >>> assert isinstance(DateFormat("%m/%d/%y").parse("05/12/09"), Date)
        """
        return Date(datetime.datetime.strptime(str, self.fmt))
        
    def format(self, date):
        """
        Format a date using this format.
        >>> assert isinstance(DateFormat("%m/%d/%y").format(now()), str)
        """
        return date.format(self.fmt)
        

def say_amount(num, unit):
    if abs(num) > 1:
        s = 's'
    else:
        s = ''
    return "%d %s%s" % (num, unit, s) 

def say_less_than(num, unit):
    if num == 1 and unit == 'minute':
        return "less than a minute"
    else:
        return "less than " + say_amount(num, unit)

def say_about(num, unit):
    return "about " + say_amount(num, unit)
    
def say_over(num, unit):
    return "over " + say_amount(num, unit)

class Date(object):
    def __init__(self, dt):
        self.date = dt
        
    def __add__(self, interval):
        """
        Return a Date by adding a TimeInterval to this date.
        >>> assert today() + hours(5) > today()
        """
        return Date(self.date + interval.delta)
        
    def __sub__(self, date_or_inter):
        """
        Return a Date by subtracting a time interval from this date or
        return a TimeInterval by subtracting another date from this date.
        >>> assert isinstance(now() - today(), TimeInterval)
        >>> assert isinstance(now() - minutes(5), Date)
        >>> assert (hours(5).from_today() - hours(3).from_today()) == hours(2)
        """
        if isinstance(date_or_inter, TimeInterval):
            return Date(self.date - date_or_inter.delta)
        elif isinstance(date_or_inter, Date):
            return TimeInterval(self.date - date_or_inter.date)
        else:
            raise Exception("__sub__ operation not supported for %s." % type(date_or_inter))
        
    def format(self, format="%m/%d/%y %I:%M%p"):
        """
        >>> assert isinstance(today().format(), str)
        """
        return self.date.strftime(format)

    def _gethour(self):
        return self.date.hour
    def _getminute(self):
        return self.date.minute
    def _getsecond(self):
        return self.date.second
    def _getday(self):
        return self.date.day
    def _getmonth(self):
        return self.date.month
    def _getyear(self):
        return self.date.year
            
    hour = property(_gethour)
    minute = property(_getminute)
    second = property(_getsecond)    
    day = property(_getday)
    month = property(_getmonth)
    year = property(_getyear)
    
    def __gt__(self, other):
        """
        >>> assert now() > minutes(5).ago()
        """
        if isinstance(other, Date):
            return self.date > other.date
        else:
            return False
        
    def __lt__(self, other):
        """
        >>> assert minutes(5).ago() < now()
        """
        if isinstance(other, Date):
            return self.date < other.date
        else:
            return False
    
    def __eq__(self, other):
        """
        >>> assert today() == today()
        """
        if isinstance(other, Date):
            return self.date == other.date
        else:
            return False
    
    def __str__(self):
        return self.format()
        
    def __repr__(self):
        return "Date(%s)" % self.__str__()
        
class TimeInterval(object):
    def __init__(self, td):
        self.delta = td
    
    def __add__(self, date_or_delta):
        """
        >>> assert isinstance(weeks(2) + days(2), TimeInterval)
        """
        if isinstance(date_or_delta, Date):
            return Date(self.delta + date.date)
        elif isinstance(date_or_delta, TimeInterval):
            return TimeInterval(self.delta + date_or_delta.delta)
        else:
            raise Exception("__add__ operation not supported for type %s" % type(date_or_delta))
    
    def _and(self, delta):
        """
        >>> assert (day(1) + hours(3)) == day(1)._and(hours(3))
        """
        return self + delta
    
    def __mul__(self, num):
        """
        Multiply this interval by num.
        >>> assert (minutes(5) * 5) == minutes(25)
        """
        return TimeInterval(self.delta * num)
    
    def __div__(self, num):
        """
        Divid this interval by num.
        >>> assert (minutes(25) / 5) == minutes(5)
        """
        return TimeInterval(self.delta / num)
        
    def __gt__(self, interval):
        """
        Whether this interval is greater than the other interval.
        >>> assert minute(1) > minute(0)
        """
        if isinstance(interval, TimeInterval):
            return self.delta > interval.delta
        else:
            return False
            
    def __lt__(self, interval):
        """
        Whether this interval is less than the other interval.
        >>> assert minute(1) < minute(2)
        """
        if isinstance(interval, TimeInterval):
            return self.delta < interval.delta
        else:
            return False
            
    def __neg__(self):
        """
        Negate this time interval.
        >>> assert (-minutes(5)) < minute(0)
        >>> assert (--minutes(5)) == minutes(5)
        """
        return TimeInterval(-self.delta)
        
    def __eq__(self, other):
        """
        Whether this interval is the same as the other.
        >>> assert weeks(2) == days(14)
	    >>> assert minutes(5) == seconds(5 * 60)
	    >>> assert day(1) == hours(24)
        """
        if isinstance(other, TimeInterval):
            return self.delta == other.delta
        else:
            return False
        
    def _from(self, date):
        """
        Returns a Date by adding this interval to date
        assert isinstance(days(2)._from(today()), Date)
        assert today() + hours(5) == hours(5)._from(today())
        """
        return date + self
        
    def from_today(self):
        """
        Returns a Date equal to this interval from today.
        >>> assert days(1)._from(today()), days(1).from_today()
        """
        return self._from(today())
        
    def from_now(self):
        """
        Returns a Date equal to this interval from now.
        >>> assert isinstance(day(1).from_now(), Date)
        """
        return self._from(now())
    
    def ago(self):
        """
        Returns a Date by subtracting this interval from now()
        >>> assert minutes(5).ago() < now()
        """
        return self.before(now())
        
    def before(self, date):
        """
        Returns a Date by subtracting this interval from date
        >>> assert hours(5).before(today()) == (today() - hours(5))
        """
        return date - self

        
    def in_words(self, include_seconds=False):
        """
        Returns the approximate time interval in words. This function is a port of the
        rails date helper method distance_of_time_in_words.
        >>> print(minutes(50).in_words())
        about 1 hour
        >>> print(seconds(15).in_words())
        less than a minute
        >>> print(seconds(15).in_words(True))
        less than 20 seconds
        >>> print(years(3).in_words())
        over 3 years
        >>> print(hours(60).in_words())
        about 3 days
        >>> print(seconds(45).in_words(True))
        less than a minute
        >>> print(seconds(76).in_words())
        1 minute
        >>> print(year(1)._and(days(3)).in_words())
        about 1 year
        >>> print(years(4)._and(days(9))._and(minutes(30))._and(seconds(5)).in_words())
        over 4 years
        >>> print(years(6)._and(days(19)).in_words())
        over 6 years
        >>> print((-years(6)._and(days(10))).in_words())
        over 6 years
        >>> print((now() - now()).in_words())
        less than a minute
        """
        sec = abs(self.delta.days * SECONDS_IN_A_DAY + self.delta.seconds)
        min = round(float(sec) / 60)
        if 0 <= min <= 1:
            if not include_seconds:
                if min == 0:
                    return say_less_than(1, "minute")
                else:
                    return say_amount(min, "minute")
            else:
                if 0 <= sec <= 4:
                    return say_less_than(5, "second")
                elif 5 <= sec <= 9:
                    return say_less_than(10, "second")
                elif 10 <= sec <= 19:
                    return say_less_than(20, "second")
                elif 20 <= sec <= 39:
                    return "half a minute"
                elif 40 <= sec <= 59:
                    return say_less_than(1, "minute")
                else:
                    return say_amount(1, "minute")
        elif 2 <= min < 44:
            return say_amount(min, "minute")
        elif 45 <= min <= 89:
            return say_about(1, "hour")
        elif 90 <= min <= 1430:
            return say_about(round(float(min) / 60), "hour")
        elif 1440 <= min <= 2879:
            return say_amount(1, "day")
        elif 2880 <= min <= 43199:
            return say_about(round(float(min) / 1440), "day")
        elif 43200 <= min <= 86399:
            return say_about(1, "month")
        elif 86400 <= min <= 525599:
            return say_amount(round(float(min) / 43200), "month")
        elif 52560 <= min <= 1051199:
            return say_about(1, "year")
        else:
            return say_over(round(float(min) / 525600), "year")
        
    def __str__(self):
        """
        >>> print(minutes(5))
        5 minutes
        >>> print(seconds(5))
        5 seconds
        >>> print(hours(5))
        5 hours
        >>> print(days(5))
        5 days
        >>> print(days(1) + hours(5))
        1 day and 5 hours
        >>> print(day(1) + hours(2) + minutes(30))
        1 day 2 hours and 30 minutes
        >>> print(day(1) + hours(2) + minutes(30) + seconds(5))
        1 day 2 hours 30 minutes and 5 seconds
        >>> print(minute(1) + seconds(23))
        1 minute and 23 seconds
        """
        seconds = self.delta.days * SECONDS_IN_A_DAY + self.delta.seconds
        ret = []
        days = seconds / SECONDS_IN_A_DAY
        seconds = seconds % SECONDS_IN_A_DAY
        if days:
            ret.append(say_amount(days, 'day'))
        hours = seconds / SECONDS_IN_AN_HOUR
        seconds = seconds % SECONDS_IN_AN_HOUR
        if hours:
            ret.append(say_amount(hours, 'hour'))
        minutes = seconds / 60
        if minutes:
            ret.append(say_amount(minutes, 'minute'))
        seconds = seconds % 60
        if seconds or len(ret) == 0:
            ret.append(say_amount(seconds, 'second'))
        if len(ret) == 1:
            return ret[0]
        else:
            return " ".join(ret[:-1]) + " and " + ret[-1]
        
    def __repr__(self):
        return "TimeInterval(%s)" % self.__str__()


def today():
    """
    Return the Date today, with time set to 00:00:00.
    >>> assert isinstance(today(), Date)
	>>> assert today().hour == today().minute == today().second == 0
    """
    dt = datetime.datetime.today()
    dt = datetime.datetime(dt.year, dt.month, dt.day)
    return Date(dt)

def now():
    """
    Return the Date now.
    >>> assert isinstance(now(), Date)
    """
    return Date(datetime.datetime.now())

def seconds(num):
    """
    Return a TimeInterval of num seconds.
    >>> assert isinstance(seconds(5), TimeInterval)
    """
    days = num / SECONDS_IN_A_DAY
    seconds = num % SECONDS_IN_A_DAY
    return TimeInterval(datetime.timedelta(days, seconds, 0))
second = seconds

def minutes(num):
    """
    Return a TimeInterval of num minutes.
    >>> assert isinstance(minutes(5), TimeInterval)
    """
    return seconds(num * 60)
minute = minutes    
def hours(num):
    """
    Return a TimeInterval of num hours.
    >>> assert isinstance(hours(3), TimeInterval)
    """
    return minutes(60) * num
hour = hours    
def weeks(num):
    """
    Return a TimeInterval of num weeks.
    >>> assert isinstance(weeks(4), TimeInterval)
    """
    return days(7) * num
week = weeks

def days(num):
    """
    Return a TimeInterval of num days.
    >>> assert isinstance(days(2), TimeInterval)
    """
    return TimeInterval(datetime.timedelta(num))
day = days

def years(num):
    """
    Return a TimeInterval of num years.
    >>> assert year(1) == days(365)
    """
    return days(365) * num
year = years
if __name__ == '__main__':
    import doctest
    doctest.testmod()