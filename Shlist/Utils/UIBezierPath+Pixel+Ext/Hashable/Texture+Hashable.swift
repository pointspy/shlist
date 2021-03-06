//
//  Texture+Hashable.swift
//  Pixel-iOS
//
//  Created by José Donor on 18/01/2019.
//

#if USE_TEXTURE

import AsyncDisplayKit



extension ASScrollDirection: Hashable {
	public var hashValue: Int {
		return rawValue
	}
}

#endif
