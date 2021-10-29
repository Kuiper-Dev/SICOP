
export const getProcedimientosJSON = async (req, res) =>{
    
    res.download('src/downloads/json/'+req.params.id,req.params.id, function(err){
        if(err){
            console.log(err);
        }else{
            console.log('Yean Nice');
        }
    })
    console.log(__dirname);
};
export const getInstitucionesJSON = async (req, res) =>{
    
    res.download('src/downloads/json/'+req.params.id,req.params.id, function(err){
        if(err){
            console.log(err);
        }else{
            console.log('Yean Nice');
        }
    })
    console.log(__dirname);
};

export const getProveedoresJSON = async (req, res) =>{
    
    res.download('src/downloads/json/'+req.params.id,req.params.id, function(err){
        if(err){
            console.log(err);
        }else{
            console.log('Yean Nice');
        }
    })
    
    console.log(__dirname);
};