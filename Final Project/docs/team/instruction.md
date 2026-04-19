# Team Coordination Notes

## Project Topic

**Open vs. Laparoscopic Colectomy in Colorectal Cancer**

This document is a cleaned and structured version of the team coordination notes originally shared in group chat.

## Team Workstream Overview

| Person | Workstream | Core Responsibilities | Paper Sections | Presentation |
| --- | --- | --- | --- | --- |
| **Person 1** | 数据清洗 + 描述统计 | 处理缺失值、变量重编码、建立干净分析数据集、制作 Table 1、记录变量定义和数据字典 | Data Source, Study Population, Variable Definitions | 1-2 张 slides：数据来源与研究人群 |
| **Person 2** | 标准化差异 + Balance 评估 | 计算匹配前标准化差异、制作 Love Plot、补充 Table 1 的 SMD、配合匹配后 balance 评估 | Balance Assessment | 1-2 张 slides：匹配前后 balance 对比 |
| **Person 3** | 多变量回归：`DIED` | 对 `DIED` 建立多变量 logistic 回归，报告 OR、95% CI、p 值，并进行模型诊断 | Multivariable Regression for Mortality | 1-2 张 slides：死亡率回归结果 |
| **Person 4** | 多变量回归：`med_comp` | 对 `med_comp` 建立多变量 logistic 回归，报告 OR、95% CI、p 值，并进行模型诊断 | Multivariable Regression for Medical Complications | 1-2 张 slides：并发症回归结果 |
| **Person 5** | 倾向性评分估计与匹配 | 建立 propensity score 模型，完成匹配，输出匹配后数据集，并评估匹配质量 | Propensity Score Estimation and Matching | 1-2 张 slides：PS 方法与匹配质量 |
| **Person 6** | PS 匹配后结局分析 | 使用匹配数据集分析 `DIED` 和 `med_comp`，可补充敏感性分析，并制作汇总 Forest Plot | PS-Adjusted Outcome Analysis | 1-2 张 slides：PS 分析结果对比 |
| **Person 7** | 文献综述 + Discussion + 整合 | 撰写 Introduction、Discussion、Conclusion、Abstract，整合全文格式并搭建整体汇报框架 | Introduction, Discussion, Conclusion, Abstract | 开头 2-3 张 + 结尾 2-3 张 slides |

## Dependency Map

| Person | Upstream Dependency |
| --- | --- |
| Person 1 | None |
| Person 2 | Depends on Person 1 clean dataset |
| Person 3 | Depends on Person 1 clean dataset |
| Person 4 | Depends on Person 1 clean dataset |
| Person 5 | Depends on Person 1 clean dataset |
| Person 6 | Depends on Person 5 matched dataset |
| Person 7 | Can begin early; final interpretation depends on team results |

## Team Consensus

The proposed division of labor was discussed in the team chat and received general agreement from the group.

Key decision:

- Person 1 would first complete the cleaned dataset and share it with the group

## Shared Project Resources

### Files shared in chat

- `Data Cleaning+Table 1.sas`

### External working links

- PPT:
  - <https://gamma.app/docs/Open-vs-Laparoscopic-Colectomy-in-Colorectal-Cancer-e9dd1n0c42augij>
- Google Slides:
  - <https://docs.google.com/presentation/d/1TcijiyvVrk7Xm1Begd8E4IoBcq36c4CmoqgnOPxK3Xo/edit?slide=id.p3#slide=id.p3>
- Paper:
  - <https://docs.google.com/document/d/1aYTgKZkI11bgUQxntklT6S4oU2ryggxOfYPBY_GpJ9Q/edit?tab=t.y88mxnzffqbx>
- Table 1:
  - <https://docs.google.com/spreadsheets/d/1hVUxrPsseAm-XomiwXncBf4P4NwvHdSS00r8h9eM9mU/edit?usp=sharing>

## Internal Timeline Notes

Based on the team discussion:

- the major submission deadline discussed was **April 22 at 8:00 AM**
- the team discussed using **Sunday evening** as an internal checkpoint for completing individual components
- the group also discussed meeting the instructor during office hours that week

## Additional Discussion Points

- Person 2 mentioned that a **target trial emulation** idea could be placed in an appendix if needed
- the team discussed whether questions for the instructor should be raised during office hours or by email

## Practical Summary

The team workflow follows a standard staged analysis process:

1. Person 1 produces the clean analytic dataset
2. Persons 2-5 perform balance assessment, regression modeling, and propensity score matching
3. Person 6 performs matched outcome analysis
4. Person 7 synthesizes the full manuscript and presentation

## Original Note Source

This document is a structured rewrite of an internal chat record and is intended for project organization only.
