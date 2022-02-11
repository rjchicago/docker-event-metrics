const { spawn } = require('child_process');

const cmd = `
SELF_ID=$(docker ps --filter "name=$CONTAINER_NAME" --format "{{.ID}}")
SELF_PID=$(docker inspect -f "{{.State.Pid}}" $SELF_ID)
while true; do (kill -0 $PARENT_PID || kill $SELF_PID) && sleep 1; done &`;

class ParentProcessUtil {
    static init = () => {
        console.log(`ParentProcessUtil.init()`);
        console.log(`CONTAINER_NAME=${process.env.CONTAINER_NAME}`);
        console.log(`PARENT_PID=${process.env.PARENT_PID}`);
        if (process.env.PARENT_PID && process.env.CONTAINER_NAME) {
            const child = spawn(cmd, { shell: true } );
            child.stderr.pipe(process.stderr);
            child.stdout.pipe(process.stdout);
        }
    }
}

module.exports = ParentProcessUtil;
