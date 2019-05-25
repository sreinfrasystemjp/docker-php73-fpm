# docker-php73-fpm
docker php73-fpm with composer, pdo_mysql, memcaced, redis, mecab(neologd), gmagick

## Usage

```
docker pull sreinfrasystemjp/docker-php73-fpm
docker run --rm \
  sreinfrasystemjp/docker-php73-fpm \
  php -r '$mecab = new \Mecab\Tagger();
$nodes = $mecab->parseToNode("形態素解析で問題なのはなのはのような解析が難しい単語です");
foreach ($nodes as $n) {
    $items = $n->getFeature();
    $a = explode(",", $items);
    echo $a[6] . "\n";
}';
```

```
*
形態素解析
で
問題
だ
の
は
なのは
の
よう
だ
解析
が
難しい
単語
です
*
```


## Library's Version

|production|version|url|note|
|---|---|---|---|
|debian|stretch-slim|https://hub.docker.com/_/debian/ |docker image|
|php|7.3.5-fpm-stretch|https://hub.docker.com/_/php/ |mbstring,pdo_mysql,zip|
|composer|1.8.5|https://getcomposer.org/ ||
|php msgpack|2.0.3|https://pecl.php.net/package/msgpack ||
|php igbinary|3.0.1|https://pecl.php.net/package/igbinary ||
|php memcached|3.1.3|https://pecl.php.net/package/memcached ||
|php redis|4.3.0|https://pecl.php.net/package/redis ||
|php mecab|0.6.0|https://github.com/rsky/php-mecab ||
|gunosy/neologd-for-mecab(neologd/mecab-ipadic-neologd)|2019.05.24|https://github.com/gunosy/neologd-for-mecab ||
|php gmagick|2.0.5RC1|https://pecl.php.net/package/gmagick ||
|supervisord|4.0.3|https://github.com/Supervisor/supervisor |pip install|
|michaloo/go-cron|v0.0.2|https://github.com/michaloo/go-cron ||
|sreinfrasystemjp/go-redis-setlock|v0.0.1.1|https://github.com/sreinfrasystemjp/go-redis-setlock |forked from fujiwara/go-redis-setlock|


## Licence

Apache License 2.0

* Library's License

|production|license|license url|note|
|---|---|---|---|
|docker|Apache-2.0|https://github.com/moby/moby/blob/master/LICENSE ||
|debian|GPL,etc|https://www.debian.org/legal/licenses/ ||
|php|PHP-3.01|https://www.php.net/license/index.php ||
|composer|MIT|https://github.com/composer/composer/blob/master/LICENSE ||
|php msgpack|New BSD|https://pecl.php.net/package/msgpack ||
|php igbinary|BSD-3-Clause|https://pecl.php.net/package/igbinary ||
|php memcached|PHP|https://pecl.php.net/package/memcached ||
|php redis|PHP|https://pecl.php.net/package/redis ||
|php mecab|MIT|https://github.com/rsky/php-mecab ||
|neologd/mecab-ipadic-neologd|Apache-2.0|https://github.com/neologd/mecab-ipadic-neologd/blob/master/COPYING ||
|php gmagick|New BSD|https://pecl.php.net/package/gmagick ||
|supervisord|BSD-derived|https://github.com/Supervisor/supervisor/blob/master/COPYRIGHT.txt ||
|michaloo/go-cron|MIT|https://github.com/michaloo/go-cron/blob/master/LICENSE ||
|sreinfrasystemjp/go-redis-setlock|MIT|https://github.com/sreinfrasystemjp/go-redis-setlock/blob/master/LICENSE ||


## Author

[ihironao](https://github.com/ihironao)
