# Lecture-9 Security and Cryptography
若要深入了解可以学习下列课程：
* computer systems security([6.858](https://css.csail.mit.edu/6.858/2020/))
* cryptography([6.857](https://courses.csail.mit.edu/6.857/2020/), 6.875)

## Entropy（熵）
用来衡量口令的复杂度。这里就是指口令位数。

## Hash funtions
密码哈希函数(cryptographic hash function)将任意长度的数据映射到固定长度，且具有某些特性的结果集中。
作为一个例子，可以在shell中输入如下指令，查看SHA1函数的输出：
```shell
$ printf 'hello' | sha1sum
aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d
$ printf 'hello' | sha1sum
aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d
$ printf 'Hello' | sha1sum
f7ff9e8b7bb2e09b70935a5d785e0cc5d9d0abf0
```

哈希函数的特点:
* 确定性(Deterministic): 相同输入总是产生相同的输出。
* 不可逆性(Non-invertible): 难以从输出反推处输入。
* 目标抗碰撞：对于一个特定输入`m_1`, 难以找到一个与之不同的`m_2`，使得`hash(m_1) == hash(m_2)`。
* 抗碰撞：难以找到两个不同的输入`m_1`, `m_2`使两者的哈希相等。（这条比目标抗碰撞要求更严格）

注意，SHA-1的强度已无法满足当前的安全需求。
## Key derivation functions
密钥导出函数。用来生成固定长度的密钥来给其他加密算法使用。

## Symmetric cryptography
对称加密。伪码描述：
```
keygen() -> key  (this function is randomized)

encrypt(plaintext: array<byte>, key) -> array<byte>  (the ciphertext)
decrypt(ciphertext: array<byte>, key) -> array<byte>  (the plaintext)
```
对称加密特点：
* 无key时，难以从密文反推明文。
AES就是一种对称加密。

## Asymmetric cryptography
非对称加密。所谓**非对称**指的是加密和解密分别使用了两个不同的key，即公钥和私钥。
* 公钥：公开分发。
    * 用来加密信息;
    * 用来验证签名。
* 私钥：保密。
    * 用来解密公钥所加密的信息；
    * 用来进行签名（signature）。

伪码描述:
```
keygen() -> (public key, private key)  (this function is randomized)

encrypt(plaintext: array<byte>, public key) -> array<byte>  (the ciphertext)
decrypt(ciphertext: array<byte>, private key) -> array<byte>  (the plaintext)

sign(message: array<byte>, private key) -> array<byte>  (the signature)
verify(message: array<byte>, signature: array<byte>, public key) -> bool  (whether or not the signature is valid)
```

## Applications
* PGP邮件加密。人们可以将自己的公钥上传到网上（如一个PGP密钥服务器或[Keybase](https://keybase.io))。然后，其他人就可以使用公钥给这些人发送加密邮件。
* Private messaging. 诸如[Signal](https://signal.org/)和[Keybase](https://keybase.io/)等使用非对称密钥来建立私有信道的应用程序。
* 软件签名(Signing software)。Git可以具有GPG签名的提交和标签。 使用发布的公共密钥，任何人都可以验证下载的软件的真实性。

## Key distribution
虽然非对称密钥加密很优秀，但如何安全地分发公钥呢？实践中有许多种解决方案。其中
* Signal采用的方案是：信任首次使用，并支持带外公共密钥交换（您可以亲自验证朋友的“安全号码”）。
* PGP使用的是[网页信任](https://en.wikipedia.org/wiki/Web_of_trust)。
* Keybase使用的是[social proof](https://keybase.io/blog/chat-apps-softer-than-tofu)

## Case studies
### Password managers
流行的密码管理工具如：[KeePassXC](https://keepassxc.org/), [pass](https://www.passwordstore.org/), [1Password](https://1password.com/)。可以安全的管理你的各类密码，你只需要记住一个管理密码即可。而这些工具可以生成高强度、足够随机的密码。

### Two-factor authentication
两步验证，又称[双因子认证](https://en.wikipedia.org/wiki/Multi-factor_authentication)。要求用户同时使用密码（**即“你知道的信息“**）和一个省份验证验证器（**即“你拥有的东西“**， 如YubiKey，网银U盾)来消除密码泄露和钓鱼攻击（phishing）。

### Full disk encryption
若笔记本失窃，想要数据不因此泄露，最简单的方式就是将全盘数据加密。
* Linux下，可以用[cryptsetup + LUKS](https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_a_non-root_file_system)。
* Windows下，可以使用[BitLocker](https://fossbytes.com/enable-full-disk-encryption-windows-10/)。
* macOS下，可用[FileVult](https://support.apple.com/en-us/HT204837).

### Private messageing
使用Signal或Keybase等端到端加密的通讯软件，保证信息安全。

### SSH
`ssh-keygen`基于当时系统硬件事件生成公私钥对，故可以认为是随机的。`ssh-keygen`生成密钥对时还会提示用户输入密码来加密私钥，这是它采用对称加密来加密私钥的。