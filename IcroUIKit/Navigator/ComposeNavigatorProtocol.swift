//
//  Created by martin on 18.12.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation
import IcroKit

public protocol ComposeNavigatorProtocol {

    func openLinkInsertion(completion: @escaping (String?, URL?) -> Void)

    func openImageInsertion(sourceView: UIView?,
                            imageInsertion: @escaping (ComposeViewModel.Image) -> Void,
                            imageUpload: @escaping (UIImage) -> Void)

    func open(datasource: GalleryDataSource)
}
