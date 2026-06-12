#!/usr/bin/env node

/**
 * Jira Issue信息获取脚本
 * 根据当前git分支获取Jira issue的summary和customfield_10245
 */

const { execSync } = require('child_process')
const https = require('https')

// 默认配置
const DEFAULT_CONFIG = {
  jiraBaseUrl: 'https://cjira.guazi-corp.com',
  apiPath: '/rest/mobile/1.0/issue',
  expand: 'renderedFields%2Cnames%2Cschema%2Ceditmeta%2Cscreen',
  cookie:
    'GUAZISSO=0688288401qnmnqlljemvb5641000075; DEVICEID=64aab1a3dd6f4aa1830523ae52331e6f; JSESSIONID=A5C4EEB90AF9D6EFCFE197A938093F0B; miniorange.oauth.LOGOUT_COOKIE=565b2e3f-3fc5-4671-9a8b-8d5a60c2f9be; atlassian.xsrf.token=BIEI-ZNIK-BPWO-VI99_68332449adfafe8fbfb1c21979eff5f03d884bba_lin',
}

/**
 * 获取当前git分支名
 * @returns {string} 当前分支名
 */
function getCurrentBranch() {
  try {
    const branch = execSync('git rev-parse --abbrev-ref HEAD', {
      encoding: 'utf8',
      timeout: 5000,
    }).trim()
    return branch
  } catch (error) {
    console.error('❌ 获取当前分支失败:', error.message)
    process.exit(1)
  }
}

/**
 * 从分支名中提取Jira issue编号
 * @param {string} branch 分支名
 * @returns {string} Jira issue编号
 */
function extractIssueId(branch) {
  // 匹配 SFE-开头且后面接五位数字的模式
  const match = branch.match(/SFE-\d{5}/)
  if (match) {
    return match[0]
  }
  console.error('❌ 分支名称格式错误:', branch)
  console.error('💡 分支名称必须以SFE-开头，后面接五位数字')
  process.exit(1)
}

/**
 * 调用Jira API获取issue信息
 * @param {string} issueId Jira issue编号
 * @returns {Promise<Object>} Jira issue信息
 */
function getJiraIssue(issueId) {
  return new Promise((resolve, reject) => {
    const path = `${DEFAULT_CONFIG.apiPath}/${issueId}?expand=${DEFAULT_CONFIG.expand}`
    const options = {
      hostname: DEFAULT_CONFIG.jiraBaseUrl.replace('https://', ''),
      path,
      headers: {
        Accept: 'application/json',
        Cookie: DEFAULT_CONFIG.cookie,
      },
    }

    console.log(`🔗 正在请求: ${DEFAULT_CONFIG.jiraBaseUrl}${path}`)

    const req = https.request(options, (res) => {
      let data = ''
      res.on('data', (chunk) => {
        data += chunk
      })
      res.on('end', () => {
        try {
          const json = JSON.parse(data)
          resolve(json)
        } catch (error) {
          reject(new Error('解析JSON响应失败'))
        }
      })
    })

    req.on('error', (error) => {
      reject(error)
    })

    req.end()
  })
}

/**
 * 主函数
 */
function main() {
  console.log('🔍 Jira Issue信息获取工具\n')

  try {
    const branch = getCurrentBranch()
    console.log(`📋 当前分支: ${branch}`)

    const issueId = extractIssueId(branch)
    console.log(`🔖 提取的Issue ID: ${issueId}`)

    getJiraIssue(issueId)
      .then((issue) => {
        // 尝试从不同位置获取信息
        const summary = issue?.fields?.summary || '未找到summary'
        const customField =
          issue?.fields?.['customfield_10245'] || '未找到customfield_10245'

        console.log('\n✅ Jira Issue信息:')
        console.log('=====================')
        console.log(`📌 Issue ID: ${issueId}`)
        console.log(`📝 Summary: ${summary}`)
        console.log(`🔧 Custom Field 10245: ${customField}`)
        console.log('=====================')
      })
      .catch((error) => {
        console.error('❌ 获取Jira Issue信息失败:', error.message)
        process.exit(1)
      })
  } catch (error) {
    console.error('❌ 执行失败:', error.message)
    process.exit(1)
  }
}

// 处理命令行参数
const args = process.argv.slice(2)
if (args.includes('--help') || args.includes('-h')) {
  console.log('Usage: node get-jira-issue.js [options]')
  console.log('Options:')
  console.log('  --help, -h           显示帮助信息')
  console.log('  --cookie <cookie>    Jira认证cookie')
  return
}

for (let i = 0; i < args.length; i++) {
  if (args[i] === '--cookie' && args[i + 1]) {
    DEFAULT_CONFIG.cookie = args[i + 1]
  }
}

// 检查cookie是否配置
if (!DEFAULT_CONFIG.cookie) {
  console.error('❌ 没有配置cookie，请提供有效的Jira cookie')
  console.error('💡 使用方式: node get-jira-issue.js --cookie "YOUR_COOKIE"')
  process.exit(1)
}

main()
