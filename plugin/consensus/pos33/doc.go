package pos33

/**
# pos33共识算法

## 总述
当前的区块链共识算法， 除了eos外， 性能都比较差：一是出块时间长， 也就意味着交易确认的时间久；二是tps小，也就是平均每秒的确认交易量太少， 对比传统的交易服务或者支付系统， 差几个数量级别。而eos采用dpos共识算法， 由固定的21个超级节点负责区块生产， 由于网络性能和机器性能得到保障， 并且dpos采取轮流打包， 延后确认的机制， 所以出块速度非常快， 0.5s一个区块， 并且tps达到4000， 对比eth 的tps只有20， 远远胜出. 但是eos得超级节点，虽然是投票产生， 但是却类似于中心化方式运作，这和区块链的去中心化理念相悖。

pos33采用抽签算法抽出共识委员会， 共识委员会轮流生产区块， 每个区块由委员会投票确认。为保证出块迅速，每届共识委员会成员数量控制在10个左右。当这届委员会生产区块的同时， 抽取下一届的委员成员。 这样选取委员不会占用出块的时间， 并且有足够的时间能够完成委员会成员的选取。抽签算法保证对于任何参与共识的节点是公平的， 所以pos33完全是去中心化的。

采取以上算法，pos33能够稳定在1秒出块，tps可以达到500比，峰值可达3000比。

## 抵押
- 每个想参与共识的节点，需要抵押冻结单位数量的AS
- 抵押周期为7天，7天后用户可以选择继续抵押或者赎回
- 抵押单位为10,000个AS，抵押必须是整数倍个抵押单位，每个抵押单位称为1票

## 抽签
- 首先通过抽签选出共识委员会
- 每届共识委员会生产N个区块， N为给定的共识委员会投票数量，比如10
- 生产区块的数量和共识委员会拥有的票数相同

### 抽签算法
- 抽签算法：使用自己的票和给定的区块，用自己的私钥签名后，再进行sha256 Hash。

 		```Sig := Sign(Priv, Pack(B_height, B_hash, Vote_i, Round_i))```

 		```H := Sha256(Sig)```

（Pack是把公共数据序列化为二进制， Vote_i 是自己选票的索引，比如有两个选票就分别是0， 1, Round_i是循环索引，假如每票最大循环次数为3，那么Round_i取值为0，1，2）

这个抽签算法是基于两个特点：

- sha256哈希算法产生的hash值在[0, 2^256)是均匀分布的
- sign签名算法可以验证, 防止伪造：

	```Verify(Pub, Pack(B_height, B_hash, Vote_i), Sig)```

难度:

```D := Pow(2, 256) * N / Vote_all```

（Vote_all表示所有选票，N表示每届委员会预计票数, 比如10）

- 当```H < D```时， 说明选票Vote_i被抽中。
- 节点成为下届共识委员成员。
- 节点n把自己所有被抽中的选票打包位一个交易向全网广播。
- 第一届委员会的B_height == -1， 第一届委员会只有root节
- B_height % N == 0

### 多轮抽签
为保证能够选出委员会足够的票数，节点在计算抽签Hash的时候，节点的每个票可以循环多次计算（算法中的Round_i）。比如最大循环次数为3，那么抽签产生的Hash最终分为3组，如果第一组不到设定的票数N（比如10票），那么将累加第二组，如果还不够将累加第三组。通过实验，三组都不够的可能性基本为0.这样就保证了每轮抽签都有足够的票数。

如果最终累加的票数超过设定的票数N(比如10票), 那么将对票进行截取，只保留N票。为了保证公平性，将尽量保留前几轮的票。比如第一轮票数为4，第二轮13票，那么累加到第二轮，票数超过了10。那么首先对第二轮排序，取最小的6票，然后加上第一轮的4票, 共计15票。然后再对最终的10票进行排序。

## 生产区块

### 委员会切换
当本届委员会完成区块生产后，由下届委员会开始生产区块，同时，开始抽签选取新一届委员会。（所以第二节委员会的B_height = 0）

本届委员会完成的标志是：当生产的区块b_height % N == 0时，说明本届委员会完成了N个区块，任务完成。

### 生产区块
本届委员会开始生产区块之前， 需要经过排序， 即把W个选票的Hash排序，从小到大， 由持有选票的节点轮流生产区块。

#### 投票
当接受到委员会成员节点生产的高度height区块B时，其他委员会成员节点需要对B进行投票，目的是防止造成分叉。（注意：```这里的投票和抽签的选票不同，这里仅对区块投票```）

投票之前需要验证：

- 当前生产区块的节点Bp是否正确
- 区块是否正确
- 是否收集到前一个区块足够的票数，并且每个投票正确

如果验证通过， 那么执行奖励。 否则投反对票。

投票信息包括：```Sign(Priv, Pack(Bp_next, B_height, B_hash))```, 如果是反对票，```B_hash = nil```, 其中，Bp_next是下一个生产区块的节点。

当节点Bp_next收集到足够的票数， ```len(Votes) > 2/3 * N```, 节点Bp_next生产height+1区块， 广播。然后进行下一轮区块投票。


#### 奖励
每个区块奖励15个AS. 区块生产者Bp节点，委员会投票节点，剩余则发送给AS基金账户。

如果区块正确，节点Bp将被奖励，奖励的金额和Bp收集的投票成正比：
```Bp Reword := Sum(Votes) * AS * R1 + Sum(Txs_fee)```

区块完成确认后，则奖励投票节点。节点投票获取的奖励为：

```Vote Reword := R2 * w * AS``` (sum(w) < N)

R1表示生产区块奖励系数, R2表示投票奖励系数，w表示节点拥有的投票的权重（即被抽中的选票）

#### 惩罚
乱投票

## 异常

### Bp_next没有产生区块

当高度h区块B_h确认后，设置一个超时时间T，当超过时间T后，还没有接收到新区块，说明Bp_next异常，那么将由Bp_next的下一个Bp生产两个区块，一个空的h+1区块，和正常的h+2区块。其中空区块不获得奖励。

### 产生两个高度相同的区块

当节点接受到同为h的，hash不同的区块，通过判断区块收集的投票，选择票数多的。在实现上，结合chain33链难度，可以把投票的数量作为难度，写入区块。

### 委员会选取失败

每次抽签选取委员会时，设置一个超时定时器T，如果超出时间T，委员会票数不足5个，说明委员会选取失败，需要重新抽签选择。重新抽签选择区块B_height+1作为抽签的基础。


## 安全

### DDOS攻击
由于委员会是提前抽签选出后，广播到全网。所以很容易暴露。也容易遭受攻击。

但是由于pos33节点需要抵押足够的金额才能参与共识，这样可以节点防护的时候，可以白名单的方式，拒绝非抵押节点的（非交易）信息。

### 女巫攻击
同样，参与共识节点需要抵押足够的金额，采取女巫攻击在pos33里是不明智的。


*/
