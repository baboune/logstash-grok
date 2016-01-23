# logstash-grok
Practice parsing logs using Logstash and Grok

To run:

```
$ vagrant up
```

What it does:
- Launches an ubuntu 14.04 (trusty) server
- Installs java and logstash 1.5.6

To run logstash, and test the config vs the logs:
```
$ vagrant ssh
```
Then within the vagrant VM:
```
$ cd /opt/logstash/bin
$ ./logstash agent -f /vagrant/config --verbose
```

To re-run the same logs, clean up the .sincedb* that stores last offsets in files monitored by logstash.
```ruby
$ rm -rf /vagrant/.sincedb*
```

Note: It is also possible to use http://grokconstructor.appspot.com/ for testing and incremental construction of regular expressions for the grok filter that parses logfile lines for Logstash.

## Parsing syslog
The default syslog pattern is %{SYSLOGTIMESTAMP:syslog_timestamp}.

ex: 
  Mar 12 12:27:00 node-2 named[32172]: no prio, short standard syslog

But syslog can also send more advanced time like when using:
* RSYSLOG_TraditionalFileFormat - the “old style” default log file format with low-precision timestamps
* RSYSLOG_FileFormat - a modern-style logfile format similar to TraditionalFileFormat, both with high-precision timestamps and timezone information
* RSYSLOG_TraditionalForwardFormat - the traditional forwarding format with low-precision timestamps. Most useful if you send messages to other syslogd’s or rsyslogd below version 3.12.5.
* RSYSLOG_SysklogdFileFormat 

This can be changed in Ubuntu at /etc/rsyslog.conf.
```
# Comment out the next line
#$ActionFileDefaultTemplate RSYSLOG_TraditionalFileFormat
# Adding a ForwardFormat for all logs
$ActionFileDefaultTemplate RSYSLOG_ForwardFormat
```

In order to handle these more complete timestamps, a better pattern is needed. Ideally one that can handle either formats.
```
(\<%{POSINT:prio}\>)?(?:%{TIMESTAMP_ISO8601:syslog_timestamp}|%{SYSLOGTIMESTAMP:syslog_timestamp}) %{SYSLOGHOST:syslog_hostname} %{DATA:syslog_program}(:)?(\[%{POSINT:syslog_pid}\])? %{GREEDYDATA:syslog_message}
```
The pattern above can handle all the below:
  <8>2013-04-06T13:26:48.622862+01:00 node-1 rsyslogd-2027: Using prio, T and long time
  Mar 12 12:27:00 node-2 named[32172]: no prio, short standard syslog
  2016-01-21T14:02:11.472593+00:00 node-3 rsyslogd: no prio, T and long time
  <123>Jan 11 13:17:01 node-4 CRON[13599]: prio, short standard syslog


# Ceilometer

Ceilometer counters have different timpestamps based on the counter names.

This requires 3 possible (at least) possible matches on the timestamp field from the JSON event:
```
  date {
    match => [ "ceilometer_timestamp", "YYYY-MM-dd'T'HH:mm:ssZ", "YYYY-MM-dd HH:mm:ss.SSSSSSZ",  "YYYY-MM-dd'T'HH:mm:ss.SSSSSSZ", "YYYY-MM-dd HH:mm:ss.SSSSSS"]
  }
```
# Useful grok tips

## Optional element
Ssurround a pattern with ()? to make it optional.

For example, make a NUMBER matching a requestId field optional in the pattern matching:
  (%{NUMBER:requestId})?

## One of
Basically, this is when the field can be either one or the other. The inspiration came from https://github.com/elastic/logstash/blob/v1.4.2/patterns/grok-patterns IP.
```
(?:%{Pattern1}|%{Pattern2})
```
Example for either an IP in IPv4 or IPv6 format:
```
(?:%{IPV6}|%{IPV4})
```
