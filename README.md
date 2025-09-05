# KSSOLV Toolbox
KSSOLV Toolbox 是一个使用 MATLAB 语言开发的第一性原理计算工具箱。该工具箱以 **KSSOLV (Kohn-Sham Solver)** 作为计算内核，基于 MATLAB AppContainer 框架构建了直观完整的图形用户界面（GUI），旨在简化使用 KSSOLV 软件包进行 Kohn-Sham 密度泛函理论（DFT）的计算。KSSOLV Toolbox 工具箱避免了繁琐的手动脚本编写，支持自动化工作流，并集成了大语言模型（LLM）能力，能够降低使用门槛并提高研究人员的使用效率。

![KSSOLV Toolbox GUI](./assets/KSSOLV Toolbox GUI.png)

## 主要特性

KSSOLV Toolbox 采用模块化的设计： 

* **预处理模块**: 用于导入和可视化晶体结构。 
* **计算模块**: 执行自洽场（SCF）计算、非自洽场（Non-SCF）计算等相关任务。 
* **后处理模块**: 用于计算多种物理性质，例如：    
  * 电子能带结构 (Electronic Band Structures) 
  * 费米面 (Fermi Surfaces) 
* **绘图模块**: 提供大量内置绘图模板，方便快速生成出版质量的图表。

## 安装

1. 在 Windows、Mac 和 Linux 上的 MATLAB Desktop 中使用：
   - 下载 `KSSOLV_Toolbox.mltbx` 文件，双击该文件即可完成安装。
   - 安装完成后可以在 MATLAB 的 Add-Ons 插件浏览器中查看和管理 KSSOLV Toolbox。
2. 在 Windows、Mac 和 Linux 上，作为独立应用程序安装：
   - 下载独立应用程序版本的安装程序文件（体积约 1GB 左右）。
   - 运行安装程序，选择安装目标位置和 MATLAB Runtime 的安装位置，点击“开始安装”按钮后等待安装完成。

## 使用文档

请参考 [KSSOLV Toolbox 简明用户手册](https://gleamore.feishu.cn/docx/O64DdiY7LoPykxxLWAJcr0oxnfd)。

## 贡献指南

**🎯** 欢迎提交 **Issues** 和 **PR**！

- **新功能？** 请先在 Issue 中详细说明需求，讨论确认后再提交代码。
- **修复 Bug？** 可以直接提交 PR，请附上问题描述和修复方案。

本项目采用 **BSD 3-Clause** 许可证，你的贡献将被视为接受该协议。感谢你的支持！🌟
