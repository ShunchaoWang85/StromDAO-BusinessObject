/**
 * StromDAO Business Object: DirectClearing
 * =========================================
 * Directly charge for Energy delivery to an account within StromDAO Energy Blockchain.
 * 
 * DirectCharging gets used together with DirectConnections.
 * 
 * In theory account A and account B are exchanging energy metered by meter_point C
 * 
 * DirectCharging takes several DirectConnections and runs charging as soon as method chargeAll is called.
 * 
 * @author Thorsten Zoerner thorsten.zoerner@stromdao.de 
 * 
 */
 
 
this.singleclearing=function(obj_or_address) {
			if(typeof obj_or_address == "undefined") obj_or_address=parent.options.contracts["StromDAO-BO.sol_SingleClearing"];
			var p1 = new Promise(function(resolve, reject) { 
			
				var instance=parent._objInstance(obj_or_address,'StromDAO-BO.sol_SingleClearing');	
									
				instance.setAccount=function(address_account,uint256_shares)  {		
		
					var p2 = new Promise(function(resolve2, reject2) { 
							instance.obj.setAccount(address_account,uint256_shares).then(function(o) {									
								parent._waitForTransactionKeepRef(o,resolve2);												
							});									
					});
					return p2;
				};
				instance.clearing=function() {
					var p2 = new Promise(function(resolve2, reject2) { 
							instance.obj.clearing().then(function(o) {									
								parent._waitForTransactionKeepRef(o,resolve2);												
							});									
					});
					return p2;
				};
				instance.setEnergyCost=function(uint256_cost)  {		
		
					var p2 = new Promise(function(resolve2, reject2) { 
							instance.obj.setEnergyCost(uint256_cost).then(function(o) {									
								parent._waitForTransactionKeepRef(o,resolve2);												
							});									
					});
					return p2;
				};
				instance.addTx=function(address_from,address_to,uint256_value,uint256_base)  {		
		
					var p2 = new Promise(function(resolve2, reject2) { 
							instance.obj.addTx(address_from,address_to,uint256_value,uint256_base).then(function(o) {									
								parent._waitForTransactionKeepRef(o,resolve2);												
							});									
					});
					return p2;
				};
				instance.accounts=function(uint256_idx) {
					var p2 = new Promise(function(resolve2, reject2) { 
							instance.obj.accounts(uint256_idx).then(function(o) {									
								resolve2(o[0]);											
							});									
					});
					return p2;
				};
				instance.meterpoint=function() {
					var p2 = new Promise(function(resolve2, reject2) { 
							instance.obj.meterpoint().then(function(o) {									
								resolve2(o[0]);											
							});									
					});
					return p2;
				};
				instance.stromkonto=function() {
					var p2 = new Promise(function(resolve2, reject2) { 
							instance.obj.stromkonto().then(function(o) {									
								resolve2(o[0]);											
							});									
					});
					return p2;
				};
				instance.last_reading=function() {
					var p2 = new Promise(function(resolve2, reject2) { 
							instance.obj.last_reading().then(function(o) {									
								resolve2(o[0]);											
							});									
					});
					return p2;
				};				
				instance.energyCost=function() {
					var p2 = new Promise(function(resolve2, reject2) { 
							instance.obj.energyCost().then(function(o) {									
								resolve2(o[0]);											
							});									
					});
					return p2;
				};
				instance.share=function(address_account) {
					var p2 = new Promise(function(resolve2, reject2) { 
							instance.obj.share(address_account).then(function(o) {									
								resolve2(o[0].toString());											
							});									
					});
					return p2;
				};
				

				resolve(instance);
			});
			return p1;
		};