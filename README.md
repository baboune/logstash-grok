# logstash-grok
Practice parsing logs using Logstash and Grok

To run:
$ vagrant up

What it does:
- Launches an ubuntu 14.04 (trusty) server
- Installs java and logstash 1.5.6

To run logstash, and test the config vs the logs:
$ vagrant ssh
$ cd /opt/logstash/bin
$ ./logstash agent -f /vagrant/config --verbose

To re-run the same logs, clean up the .sincedb* that stores last offsets in files monitored by logstash.
$ rm -rf /vagrant/.sincedb*

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

#$ActionFileDefaultTemplate RSYSLOG_TraditionalFileFormat
$ActionFileDefaultTemplate RSYSLOG_ForwardFormat

In order to handle this, a better pattern needed to be made to handle either formats.

# Ceilometer

Ceilometer counters have different timpestamps based on the counter names.

This requires 3 possible (at least) possible matches on the timestamp field from the JSON event:

  date {
    match => [ "ceilometer_timestamp", "YYYY-MM-dd'T'HH:mm:ssZ", "YYYY-MM-dd HH:mm:ss.SSSSSSZ",  "YYYY-MM-dd'T'HH:mm:ss.SSSSSSZ", "YYYY-MM-dd HH:mm:ss.SSSSSS"]
  }

# Useful grok tips

## Optional element
Ssurround a pattern with ()? to make it optional.

For example (%{NUMBER:requestId})?

## One of
Basically, this is when the field can be either one or the other. The inspiration came from https://github.com/elastic/logstash/blob/v1.4.2/patterns/grok-patterns IP.

(?:%{Pattern1}|%{Pattern2})

Example for either an IP in IPv4 or IPv6 format:
(?:%{IPV6}|%{IPV4})
