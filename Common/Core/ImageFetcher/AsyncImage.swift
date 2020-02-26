//
//  ImageFetcher.swift
//  ProjectTV
//
//  Created by Ray Hunter on 24/02/2020.
//  Copyright © 2020 Rekall. All rights reserved.
//

import SwiftUI
import Combine

struct AsyncImage: View {
    private let image: SwiftUI.State<UIImage>
    private let source: AnyPublisher<UIImage, Never>
    private let animation: Animation?

    init(
        source: AnyPublisher<UIImage, Never>,
        placeholder: UIImage,
        animation: Animation? = nil
    ) {
        self.source = source
        self.image = SwiftUI.State(initialValue: placeholder)
        self.animation = animation
    }

    var body: some View {
        return Image(uiImage: image.wrappedValue)
            .resizable()
            .bind(source, to: image.projectedValue.animation(animation))
    }
}

extension View {
    func bind<P: Publisher, Value>(
        _ publisher: P,
        to state: Binding<Value>
    ) -> some View where P.Failure == Never, P.Output == Value {
        return onReceive(publisher) { value in
            state.wrappedValue = value
        }
    }
}

class ImageFetcher {
    private let cache = NSCache<NSURL, UIImage>()

    func image(for url: URL) -> AnyPublisher<UIImage, Never> {
        return Deferred { () -> AnyPublisher<UIImage, Never> in
            if let image = self.cache.object(forKey: url as NSURL) {
                return Result.Publisher(image)
                    .eraseToAnyPublisher()
            }

            return URLSession.shared
                .dataTaskPublisher(for: url)
                .map { $0.data }
                .compactMap(UIImage.init(data:))
                .receive(on: DispatchQueue.main)
                .handleEvents(receiveOutput: { image in
                    self.cache.setObject(image, forKey: url as NSURL)
                })
                .ignoreError()
        }
        .eraseToAnyPublisher()
    }
}

struct ImageFetcherKey: EnvironmentKey {
    static let defaultValue: ImageFetcher = ImageFetcher()
}

extension EnvironmentValues {
    var imageFetcher: ImageFetcher {
        get {
            return self[ImageFetcherKey.self]
        }
        set {
            self[ImageFetcherKey.self] = newValue
        }
    }
}

extension Publisher {
    public func ignoreError() -> AnyPublisher<Output, Never> {
        return `catch` { _ in
            Empty()
        }.eraseToAnyPublisher()
    }
}
