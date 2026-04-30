var bigInt = require("big-integer");

// Objeto global para almacenar valores memoizados
const memo = {};

// Función fibonacci con memoization recursiva
function fibonacciMemo(n) {
    // Convertir a número si es string
    n = parseInt(n);
    
    // Casos base
    if (n <= 1) return bigInt(n);
    
    // Comprobar si ya está en memo
    if (memo[n]) return memo[n];
    
    // Calcular recursivamente con memoization
    memo[n] = bigInt(fibonacciMemo(n - 1)).add(bigInt(fibonacciMemo(n - 2)));
    
    return memo[n];
}

module.exports = async function (context, req) {
    context.log('FibonacciMemo function processed a request.');
    
    try {
        let nth = req.body.nth;
        
        if (!nth && nth !== 0) {
            context.res = {
                status: 400,
                body: { error: "Please provide 'nth' in the request body" }
            };
            return;
        }
        
        if (nth < 0) {
            context.res = {
                status: 400,
                body: { error: "nth must be greater than or equal to 0" }
            };
            return;
        }
        
        // Calcular fibonacci con memoization
        let answer = fibonacciMemo(nth);
        
        context.res = {
            body: {
                nth: nth,
                result: answer.toString(),
                memoSize: Object.keys(memo).length
            }
        };
    } catch (error) {
        context.res = {
            status: 500,
            body: { error: error.message }
        };
    }
}
