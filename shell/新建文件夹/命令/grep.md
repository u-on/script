现在隆重介绍grep大神及其兄弟正则表达式。

 当当当当，grep大神是一种强大的文本搜索工具，它能使用正则表达式搜索文本，并把匹配的行打印出来。而正则表达式则是由一类特殊字符及文本字符所编写的模式，其中有些字符不表示字符字面意义，而表示控制或通配的功能。它们两个常常一起使用，在Linux运维工作中起着至关重要的作用。

------

grep命令常见用法

grep root /etc/passwd    在passwd中搜索root

grep "$USER" /etc/passwd 在passwd中搜索$USER

grep $USER /etc/passwd  在passwd中搜索$USER



![img](https:////upload-images.jianshu.io/upload_images/6908438-1e5bffb76c6da38d.JPG?imageMogr2/auto-orient/strip|imageView2/2/w/950/format/webp)

grep `whoami` /etc/passwd  在passwd中搜索root



![img](https:////upload-images.jianshu.io/upload_images/6908438-1c4b4c212014e71c.JPG?imageMogr2/auto-orient/strip|imageView2/2/w/1200/format/webp)



–color=auto 将匹配的结果着色显示



![img](https:////upload-images.jianshu.io/upload_images/6908438-8c608dae3d7ac36f.JPG?imageMogr2/auto-orient/strip|imageView2/2/w/806/format/webp)

-v: 显示不被pattern匹配到的行，反选

如：如一个文件包含许多内容，现在要显示不以t开头的文件，这时候就能派上用场了。

本来文件里的内容是：

![img](https:////upload-images.jianshu.io/upload_images/6908438-0b7da8076d601d73.JPG?imageMogr2/auto-orient/strip|imageView2/2/w/795/format/webp)

使用了grep -v 之后 就变成这样了：里面没有以t开头的文件了。



![img](https:////upload-images.jianshu.io/upload_images/6908438-85b1664caba7ac7d.JPG?imageMogr2/auto-orient/strip|imageView2/2/w/804/format/webp)

-i 忽略大小写

如：在文件f1中写入一些内容，如下：



![img](https:////upload-images.jianshu.io/upload_images/6908438-aec32bdccc587c55.JPG?imageMogr2/auto-orient/strip|imageView2/2/w/810/format/webp)

使用grep -I “^t” 命令，意思是显示以t开头的字符，不区分大小写，结果如下：



![img](https:////upload-images.jianshu.io/upload_images/6908438-3ea65cb06fc1e8f6.JPG?imageMogr2/auto-orient/strip|imageView2/2/w/802/format/webp)

-o 仅显示匹配到的字符串



![img](https:////upload-images.jianshu.io/upload_images/6908438-ad58e4bb2d1a73d9.JPG?imageMogr2/auto-orient/strip|imageView2/2/w/807/format/webp)

-q静默模式，不输出任何信息或者&> /dev/null

> grep-q"test" filename
>
> \#不会输出任何信息，如果命令运行成功返回0，失败则返回非0值。一般用于条件测试。

-A#  显示关键字行及向后#行

> \#显示匹配某个结果之后的3行，使用 -A 选项：
>
> seq 10 | grep "5"-A 3
>
> 5
>
> 6
>
> 7
>
> 8

-B#  显示关键字行及向前#行

> \#显示匹配某个结果之前的3行，使用 -B 选项：
>
> seq 10 | grep "5"-B 3
>
> 2
>
> 3
>
> 4
>
> 5

-C#显示关键字向前#行，当前行，及向后#行

> \#显示匹配某个结果的前三行和后三行，使用 -C 选项：
>
> seq 10 | grep "5"-C 3
>
> 2   3   4   5   6   7   8

-e关键字1 -e 关键字2 实现多个选项间的逻辑or关系

> echo this is a text line | grep-e"is"-e"line" -o
>
> is
>
> line

-w匹配整个单词

-E使用扩展正则表达式 或egrep

grep -E 除了\<和\>，其他的例如{ }、( )，没有添加-E时，\{\}表示范围，添加了-E选项后，直接{}表示范围。

-F不使用正则表达式 或 fgrep

基本正则表达式元字符：

字符匹配：

\ 表示忽略正则表达式中特殊字符的原有含义

[]单个字符，[A]

[^] 匹配指定范围外的任意单个字符

[ - ]匹配一个范围，[0-9a-zA-Z]匹配所有数字和字母

. 匹配任意单个字符

[:upper:] 或 [A-Z]

[:lower:] 或 [a-z]

[:blank:] 空白字符（空格和制表符）

[:space:] 水平和垂直的空白字符（比[:blank:]包含的范围广）

[:digit:] 十进制数字 或[0-9]

次数匹配：

*匹配前面的字符出现0次或者多次 贪婪模式：尽可能长的匹配

\+匹配前面的字符出现了一次或者多次

\? 匹配其前面的字符0或1次

\{n\} 匹配前面的字符n次

\{m,n\} 匹配前面的字符至少m次，至多n次

\{,n\} 匹配前面的字符至多n次

\{n,\} 匹配前面的字符至少n次

位置锚点：对特定位置进行定位

^ 匹配正则表达式的开始行

$ 匹配正则表达式的结束行

如：^$:空行，不包含有空格的行

^[[:space:]]*$:空行，但包含有空格的行。

\<或\b 从匹配正则表达式的行开始

\> 或\b到匹配正则表达式的行结束

\<PATTERN\> 匹配整个单词

分组：\( \)将一个或多个字符捆绑在一起，当作一个整体进行处理。

如：\(xy\)*ab  表示xy这个整体可以出现任意次。

\(和\)必须成对出现，并且他们被当作一个整体进行处理，并且分组括号中的模式匹配到的内容会被正则表达式引擎记录于内部的变量中，命名方式：\1，\2，\3…

如：\(ab\+\(xy\)*\)

\1：ab\+\(xy\)*

\2：xy

后向引用：引用前面的分组括号中的模式所匹配字符，而非模式本身

或者：\|

如：a\|b: a或b   \(C\|c\)at:Cat或cat

扩展正则表达式元字符

.: 任意单个字符

[ ] : 匹配指定范围内的任意单个字符;

[^]:匹配指定范围外的任意单个字符 ;

*:匹配紧挨着其前面的字符任意次

+:匹配其前面的字符至少1次

? 匹配其前面的字符0或1次

{m,n}:至少m次，至多n次

()：分组，用括号括起来表示要引用的内容，不需要转义

a|b:二选一

------

实战演习：

1、显示/proc/meminfo文件中以大写S或小写s开头的行；(要求：使用两种方式)

cat /proc/meminfo|grep "^[Ss]"

cat /proc/meminfo|grep -i "^s"

cat /proc/meminfo|grep -e ^s -e ^S

cat /proc/meminfo|grep "^s\|^S"

cat /proc/meminfo|grep "^[s\|S]"

2、显示/etc/passwd文件中不以/bin/bash结尾的行

grep -v "/bin/bash$" /etc/passwd

3、显示用户rpc默认的shell程序

grep "^rpc\>" /etc/passwd |cut -d: -f7

或grep -w "^rpc"  /etc/passwd | cut -d : -f7

或cat /etc/passwd|grep "^rpc:"|cut -d: -f7

4、找出/etc/passwd中的两位或三位数

grep -o "\<[0-9]\{2,3\}\>" /etc/passwd

5、显示/etc/grub2.cfg文件中，至少以一个空白字符开头的且后面存非空白字符的行

grep "^[[:space:]]\+[^[:space:]]" /etc/grub2.cfg



作者：优果馥斯
链接：https://www.jianshu.com/p/f1d0739b141f
来源：简书
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。