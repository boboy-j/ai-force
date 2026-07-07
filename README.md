# 智联未来 · AIForce — 让AI真正落地

> 企业智能化转型伙伴 | 专注 AI 落地的实战团队

一支 15 人的精锐 AI 研究团队，帮助各行各业的客户将人工智能技术转化为可量化、可复制的业务成果。

## 📋 项目简介

这是 **智联未来 · AIForce** 团队的推广门户网站，一个静态单页应用（SPA），涵盖：

- **首页** — 团队介绍与核心数据
- **行业场景** — 14+ 行业 AI 落地场景展示（数字政府、智能制造、智慧医疗、金融科技等）
- **落地案例** — 40+ 实战案例，涵盖多行业客户
- **团队能力** — 6 大核心服务能力与「落地五步法」
- **合作模式** — 灵活的合作方式（项目制 / 长期伙伴 / 能力共建）
- **联系我们** — 合作咨询表单与联系方式

## 🚀 快速部署

### 方式一：Netlify（推荐，含表单采集）

1. Fork 或 Clone 本仓库
2. 登录 [Netlify](https://app.netlify.com/)，点击 **"Add new site" → "Import an existing project"**
3. 选择 GitHub，关联本仓库
4. 部署设置保持默认，直接部署
5. 部署完成后，在 **Forms** 选项卡设置邮件通知，即可采集表单数据

### 方式二：Formspree（备选表单方案）

1. 在 [Formspree](https://formspree.io/) 注册并创建一个新表单
2. 拿到 Form ID（如 `https://formspree.io/f/xxxxxx`）
3. 将 `index.html` 中表单的 `action` 属性改为你的 Formspree 链接
4. 部署到任意静态托管平台（GitHub Pages、Vercel 等）

### 方式三：GitHub Pages

1. 在仓库 Settings → Pages 中开启 GitHub Pages
2. 选择 `main` 分支，根目录
3. 访问 `https://boboy-j.github.io/ai-force/`

## 🛠️ 技术栈

- 纯 HTML + CSS + JavaScript（单文件 SPA）
- 无框架依赖，零构建步骤
- 深色/浅色主题切换（localStorage 持久化）
- 响应式设计（桌面 / 平板 / 手机三端适配）
- Netlify 原生表单支持（`data-netlify="true"`）

## 📁 文件结构

```
├── 智联未来_AIForce_团队推广门户.html   ← 单页应用（全部代码）
└── README.md                              ← 本文件
```

## 🎨 设计风格

Apple / Linear / Stripe 风格极简设计：
- 低饱和度 Indigo 主题色
- 毛玻璃导航栏
- 卡片式内容布局
- 平滑过渡动画

## 📬 联系我们

- 邮箱：ai-launcher@example.com
- 微信：AI-Launcher-Team
- 坐标：中国 · 上海

---

*© 2025 智联未来 · AIForce · 让AI真正落地*