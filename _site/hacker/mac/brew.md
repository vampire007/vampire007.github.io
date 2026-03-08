# 查看源
查看核心仓库源
```shell
git -C "$(brew --repo)" remote -v
```

核心软件包源
```shell
git -C "$(brew --repo homebrew/core)" remote -v
```

# 更换为国内源
```shell
# 替换 brew.git
git -C "$(brew --repo)" remote set-url origin https://mirrors.ustc.edu.cn/brew.git

# 替换 homebrew-core.git
git -C "$(brew --repo homebrew/core)" remote set-url origin https://mirrors.ustc.edu.cn/homebrew-core.git
```

# 设置环境变量
在 ～/.zshrc 中填写如下配置
m1/m2/m3
```shell
# 对于 Apple Silicon Mac (M1/M2/M3芯片)
export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.ustc.edu.cn/brew.git"
export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.ustc.edu.cn/homebrew-core.git"
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles/bottles"
export HOMEBREW_API_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles/api"

# 对于 Intel Mac，注释掉上面的 HOMEBREW_BOTTLE_DOMAIN 和 HOMEBREW_API_DOMAIN，使用下面这行
# export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles"
```

intel mac 
```shell
export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.ustc.edu.cn/brew.git"
export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.ustc.edu.cn/homebrew-core.git"
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles"
```

# 保存配置并更新源
```shell
source ~/.zshrc

brew update
```