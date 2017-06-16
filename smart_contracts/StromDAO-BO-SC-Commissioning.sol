pragma solidity ^0.4.10;
/**
 * StromDAO Business Objects
 * ====================================================================
 * Upper level business objects required for power delivery on a public
 * energy distribution system. Defines PowerDelivery as digital asset
 * used for transaction data and entities (roles) for master data.
 * 
 * @author Thorsten Zoerner <thorsten.zoerner(at)stromdao.de)
 **/


contract owned {
	address public owner;
	event Transfered(address old_owner,address new_owner);
	function owned() {
		owner = msg.sender;
	}

	modifier onlyOwner {
		if (msg.sender != owner) throw;
		_;
	}
	
	modifier onlyOwnerAsOriginator {
		if (tx.origin != owner) throw;
		_;
	}
	
	function transferOwnership(address newOwner) onlyOwner {
		Transfered(owner,newOwner);
		owner = newOwner;
	}
}

contract StringStorage {
	string public str;
	
	function StringStorage(string _str) {
		str=_str;
	}
}

contract StringStorageBuilder {
	event Built(address _stringStorage);
	
	function build(string _str) returns(address) {
			StringStorage ss = new StringStorage(_str);
			Built(address(ss));
			return address(ss);
	}
}




/**
 * RoleLookup
 * 
 * ====================================================================
 * Provides entity relation model (yellowpages, who-implements-what)
 * to StromDAO Business Objects. A single consensframe must always share
 * a single RoleLookup deployment.
 */
contract RoleLookup {
	mapping(uint256 => uint8) public roles;
	mapping(address=>mapping(uint8=>address)) public relations;
	 mapping(address=>mapping(address=>uint8)) public relationsFrom;
	mapping(uint8=>address) public defaults;
	event Relation(address _from,uint8 _for, address _to);
	
	function RoleLookup() {
		roles[0]= 0;
		roles[1]= 1;
		roles[2]= 2;
		roles[3]= 3;
		roles[4]= 4;
		roles[5]= 5;
	}
	function setDefault(uint8 _role,address _from) {
		if(msg.sender!=address(0xD87064f2CA9bb2eC333D4A0B02011Afdf39C4fB0)) throw;
		defaults[_role]=_from;
	}
	function setRelation(uint8 _for,address _from) {
		relations[msg.sender][_for]=_from;
		Relation(_from,_for,msg.sender);
	}
	function setRelationFrom(uint8 _for,address _from) {
		relationsFrom[msg.sender][_from]=_for;
		Relation(_from,_for,msg.sender);
	}
}

contract MPReading is owned {
	MPO public mpo;
	mapping(address=>reading) public readings;
	event Reading(address _meter_point,uint256 _power);
	
	struct reading {
		uint256 time;
		uint256 power;
		
	}
	
	function setMPO(MPO _mpo) onlyOwner {
		mpo=_mpo;
	}
	
	function storeReading(uint256 _reading) {
			if(address(mpo)!=address(0x0))  {
				mpo.storeReading(_reading);
			} else {
				readings[tx.origin]=reading(now,_reading);           
			}
			Reading(tx.origin,_reading);
	}
	
}

contract MPO is owned {
	
	  function storeReading(uint256 i) onlyOwner {
	  }
}

contract MPReadingGenesis {
	MPO public mpo;
	mapping(address=>reading) public readings;
	event Reading(address _meter_point,uint256 _power);
	
	struct reading {
		uint256 time;
		uint256 power;
		
	}
	
	function setMPO(MPO _mpo) {
		if(msg.sender!=address(0xD87064f2CA9bb2eC333D4A0B02011Afdf39C4fB0)) throw;
		mpo=_mpo;
	}
	
	function storeReading(uint256 _reading) {
			if(address(mpo)!=address(0x0))  {
				mpo.storeReading(_reading);
			} else {
				readings[tx.origin]=reading(now,_reading);           
			}
			Reading(tx.origin,_reading);
	}
	
}


contract TxHandler is owned  {
	
	  function addTx(address _from,address _to, uint256 _value,uint256 _base) onlyOwner {
	  }
	
}

contract Stromkonto is TxHandler {
 
	event Transfer(address indexed _from, address indexed _to, uint256 _value);
	event Tx(address _from,address _to, uint256 _value,uint256 _base,uint256 _from_soll,uint256 _from_haben,uint256 _to_soll,uint256 _to_haben);
	
	mapping (address => uint256) public balancesHaben;
	mapping (address => uint256) public balancesSoll;
	
	mapping (address => uint256) public baseHaben;
	mapping (address => uint256) public baseSoll;
	uint256 public sumTx;
	uint256 public sumBase;
	
	function transfer(address _to, uint256 _value) returns (bool success) { return false; throw;}
	

	function balanceHaben(address _owner) constant returns (uint256 balance) {
		return balancesHaben[_owner];
	}
	
	function balanceSoll(address _owner) constant returns (uint256 balance) {
		return balancesSoll[_owner];
	}

	
	function addTx(address _from,address _to, uint256 _value,uint256 _base) onlyOwner {
		balancesSoll[_from]+=_value;
		baseSoll[_from]+=_value;
		balancesHaben[_to]+=_value;
		baseHaben[_to]+=_value;
		sumTx+=_value;
		sumBase+=_base;
		Tx(_from,_to,_value,_base,balancesSoll[_from],balancesHaben[_from],balancesSoll[_to],balancesHaben[_to]);
	}
	
}

contract StromkontoProxyFactory {
	event Built(address _sp,address _account);
	
	function build() returns(StromkontoProxy) {
		StromkontoProxy sp = new StromkontoProxy();
		sp.modifySender(msg.sender,true);
		sp.transferOwnership(msg.sender);
		Built(address(sp),msg.sender);
		return sp;
	}
	
}

contract StromkontoProxy is Stromkonto {
		
		mapping(address=>bool) public allowedSenders;
		
		function StromkontoProxy() {
				allowedSenders[msg.sender]=true;
		}
		function modifySender(address _who,bool _allow) onlyOwner {
				//if(msg.sender!=address(0xD87064f2CA9bb2eC333D4A0B02011Afdf39C4fB0)) throw;
				allowedSenders[_who]=_allow;
		}
		
		function addTx(address _from,address _to, uint256 _value,uint256 _base)  {
			if(allowedSenders[msg.sender]) {
				balancesSoll[_from]+=_value;
				baseSoll[_from]+=_value;
				balancesHaben[_to]+=_value;
				baseHaben[_to]+=_value;
				Tx(_from,_to,_value,_base,balancesSoll[_from],balancesHaben[_from],balancesSoll[_to],balancesHaben[_to]);
			}
		}
		
}

contract Connection {
	address public from;
	address public to;
	
	function Connection(address _from,address _to) {
			from=_from;
			to=_to;
	}	
}

contract PricingEnergy {
	uint256 public cost_per_energy;
	
	function PricingEnergy(uint256 _cost_per_energy) {			
			cost_per_energy=_cost_per_energy;
	}	
}

contract PricingDay {
	uint256 public cost_per_day;
	
	function PricingDay(uint256 _cost_per_day) {			
			cost_per_day=_cost_per_day;
	}	
}

contract MPSetFactory {
		event Built(address _mpset,address _account);
	
		function build() returns(address) {			
				MPset mpset = new MPset();
				mpset.transferOwnership(msg.sender);
				Built(address(mpset),msg.sender);
				return address(mpset);
		}
	
}
contract MPset is owned {
	
	address[] public meterpoints;
	mapping(address=>bool) public mps;
	event added(address _meterpoint);
	
	function addMeterPoint(address _meterpoint)  {
		//TODO Allow Selfregister only in DEV - add onlyOwner in Production
		if(!mps[_meterpoint]) {
			meterpoints.push(_meterpoint);
			mps[_meterpoint]=true;
			added(_meterpoint);
		}
	}
	
	function length() returns(uint256) {
			return meterpoints.length;
	}
	/*
	 function copy(address[] storage mps) {
		 //address[] storage mps=new address[meterpoints.length];
		 for(uint i=0;i<meterpoints.length;i++) {
			mps.push(meterpoints[i]);	 
		 }			
	}
	*/
}

contract MPR {
	mapping(address=>uint256) public mpr;
	mapping(address=>uint256) public mpr_base;
}

contract MPRSetFactory {
	event Built(address _mpset,address _account);
	
	function build(MPset _mpset,MPReading _reading) returns(MPRset) {
		MPRset mprset = new MPRset(_mpset,_reading);
		Built(address(mprset),msg.sender);
		return mprset;
	}
	
}
contract MPRset is MPR {
	address[] public meterpoints;
	
	function MPRset(MPset _mpset,MPReading _reading) {
		for(uint i=0; i<_mpset.length();i++) {
		
			meterpoints.push(_mpset.meterpoints(i));
			
			uint256 time;
			uint256 reading;
			address mp = _mpset.meterpoints(i);
			(time,reading)=_reading.readings(mp);			
			mpr[mp]=reading;
			
			
			
		}
		/*	
		for(uint i=0; i<_mpset.length();i++) {
					meterpoints.push(_mpset.meterpoints(i));
		}		
		/*		
		for(i=0;i<meterpoints.length;i++) {				
				uint256 time;
				(time,mpr[meterpoints[i]])=_reading.readings(meterpoints[i]);
		}
		*/		
	}		
}

contract MPRsum {
	uint256 public sum;
	
	function MPRsum(address[] meterpoints,MPR mpr) {
		for(uint i=0;i<meterpoints.length;i++) {
			sum+=mpr.mpr(meterpoints[i]);
		}	
	}	
}

contract MPRDecorateFactory {
	
	event Built(address _mpset,address _account);
	
	function build(MPset _mpset,MPR _set_start,MPR _set_end) returns(MPRdecorate) {
		MPRdecorate mprd = new MPRdecorate(_mpset,_set_start,_set_end);
		mprd.transferOwnership(msg.sender);
		Built(address(mprd),msg.sender);
		return mprd;
	}
	
}
contract MPRdecorate is MPR, owned {
	address[] public meterpoints;	
	event Decorated(uint _cnt);

	function MPRdecorate(MPset _mpset,MPR _set_start,MPR _set_end) {
			for(uint i=0; i<_mpset.length();i++) {
					meterpoints.push(_mpset.meterpoints(i));
			}		
			
			for( i=0;i<meterpoints.length;i++) {					
					if(_set_start.mpr(meterpoints[i])<_set_end.mpr(meterpoints[i])) {
						mpr[meterpoints[i]]=_set_end.mpr(meterpoints[i])-_set_start.mpr(meterpoints[i]);
						mpr_base[meterpoints[i]]=_set_end.mpr(meterpoints[i])-_set_start.mpr(meterpoints[i]);
					} else {
						mpr[meterpoints[i]]=_set_end.mpr(meterpoints[i]);
						mpr_base[meterpoints[i]]=_set_end.mpr(meterpoints[i]);
					}
			}
			Decorated(meterpoints.length);											
	}
	
	
	function ChargeEnergy(uint amount) onlyOwner {
		for(uint i=0;i<meterpoints.length;i++) {
				mpr[meterpoints[i]]*=amount;
		}
		Decorated(meterpoints.length);
	}	
	
	function ChargeFix(uint amount) onlyOwner {
		for(uint i=0;i<meterpoints.length;i++) {
				mpr[meterpoints[i]]+=amount;
		}
		Decorated(meterpoints.length);
	}	
	
	function Add(MPR mpr2) onlyOwner {
		for(uint i=0;i<meterpoints.length;i++) {
			mpr[meterpoints[i]]+=mpr2.mpr(meterpoints[i]);
		}
		Decorated(meterpoints.length);
	}
	
	function SplitWeighted(uint256 amount) onlyOwner {
		MPRsum ctr_sum = new MPRsum(meterpoints,this);
		uint256 sum = ctr_sum.sum();
		
		for(uint i=0;i<meterpoints.length;i++) {
				mpr[meterpoints[i]]+=amount*(mpr[meterpoints[i]]/sum);
		}
		Decorated(meterpoints.length);
	}	
	
	function SplitEqual(uint256 amount) onlyOwner {
		for(uint i=0;i<meterpoints.length;i++) {
				mpr[meterpoints[i]]+=amount/meterpoints.length;
		}
		Decorated(meterpoints.length);
	}			
	
}

contract TXCache is owned {
	
	struct TX {
			address from;
			address to;
			uint256 base;
			uint256 value;
	}
	
	event addedTx(address _from,address _to,uint256 _base,uint256 _value);
	
	TX[] public txs;
	
	function addTx(address _from,address _to,uint256 _base,uint256 _value) onlyOwner {
			txs.push(TX(_from,_to,_base,_value));
			addedTx(_from,_to,_base,_value);
	}
	function length() returns(uint256) {
			return txs.length;
	}
	
	function from(uint i) returns(address) {
			return txs[i].from;
	}
	function to(uint i) returns(address) {
			return txs[i].to;
	}
	function base(uint i) returns(uint256) {
			return txs[i].base;
	}
	function value(uint i) returns(uint256) {
			return txs[i].value;
	}
}

contract SettlementFactory {
	
	event Built(address _settlement,address _account);
	
	function build(MPset _mpset,bool _toOwner) returns(Settlement) {
		Settlement settlement = new Settlement(_mpset,_toOwner);
		//settlement.transferOwnership(msg.sender);
		Built(address(settlement),msg.sender);
		return settlement;
	}
	
}
contract Settlement {
		address[] public meterpoints;	
	    TXCache public txcache;
		bool _toOwner;
		
	    event Settled(address txcache,address tx,bool toOwner);
	    
		function Settlement(MPset _mpset,bool toOwner) {
			for(uint i=0; i<_mpset.length();i++) {
					meterpoints.push(_mpset.meterpoints(i));
			}				
			_toOwner=toOwner;
			txcache = new TXCache();
			//settle();
		}	
		
		function settle(MPR _tx) {
			//if(address(txcache.owner)!=address(this)) return;
			
			for(uint i=0;i<meterpoints.length;i++) {
				if(_toOwner) {
						txcache.addTx(meterpoints[i],address(this),_tx.mpr(meterpoints[i]),_tx.mpr_base(meterpoints[i]));									
				} else {
						txcache.addTx(address(this),meterpoints[i],_tx.mpr(meterpoints[i]),_tx.mpr_base(meterpoints[i]));			
				}
				
			}
			Settled(address(txcache),address(_tx),_toOwner);
			txcache.transferOwnership(msg.sender);
		}
}




