import sql from 'mssql';

const dbSettings={
    user:'administrador',
    password:'D@tawarehouse.26',
    server: 'mssql-46421-0.cloudclusters.net',
    database:'dw_sicop',
    port:18887,
    options:{
        encrypt:true,
        trustServerCertificate:true
    }
};
export async function getConnection(){
    try{
        const pool= await sql.connect(dbSettings);
        return pool;
    }catch(error){
        console.log(error);
    }
}

