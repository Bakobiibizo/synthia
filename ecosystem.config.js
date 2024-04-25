    module.exports = {
    apps: [
        {
            name: `${process.env.MODULE_KEYNAME}`,
            script: 'src/synthia/cli.py',
            interpreter: 'python',
            args: process.env.MODULE_PATH,  // Using environment variable
            watch: true,
            env: {
                MODULE_ENV: 'development',
                MODULE_PATH: `${process.env.MODULE_PATH}`, // Default path that can be overridden
            }
        },
        {
            name: `${process.env.MODULE_KEYNAME}`,
            script: 'comx',
            args: `module serve --ip "${process.env.MODULE_IP}" --port "${process.env.MODULE_PORT}" --subnets-whitelist "${process.env.MODULE_NETUID}" "synthia.miner.${process.env.MODULE_PATH}" "${process.env.MODULE_KEYNAME}"`,
            watch: true,
            env: {
                MODULE_ENV: 'development',
                MODULE_IP: '0.0.0.0', // Default IP
                MODULE_PORT: '8000',    // Default Port
                MODULE_NETUID: '3',   // Default Netuid
                MODULE_PATH: 'anthropic.AnthropicModule',
                MODULE_KEYNAME: 'module',
                MODULE_STAKE: '300'
            }
        }
    ]
};
